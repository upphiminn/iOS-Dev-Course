//
//  FindSmileyFetcher.m
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "FindSmileyFetcher.h"
#define FINDSMILEY_BASE_URL @"http://www.findsmiley.dk/da-DK/Searching/TableSearch.htm?searchtype=all"
#define SMILEY_DEBUG        NO
#define RESULTS_PER_PAGE    10

#import "TFHpple.h"
#import "SmileyReport.h"

@implementation FindSmileyFetcher

+ (NSArray*) executeCrawlerQuery:(NSDictionary*) parameters returnAllResults:(BOOL) allResultsMode
{
    NSString* query = [[NSMutableString alloc] initWithString:FINDSMILEY_BASE_URL];
    
    for(NSString* parameter in parameters){
        query = [query stringByAppendingFormat:@"&%@=%@",parameter,[parameters objectForKey:parameter]];
    }
    
    //url encode
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (SMILEY_DEBUG)
        NSLog(@"[%@ %@] sent %@",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd),
              query);
    
    //get the data
    NSData *queryHTMLResultsPage = [NSData dataWithContentsOfURL:[NSURL URLWithString: query]
                                                         options:nil
                                                           error:nil];
    if (SMILEY_DEBUG)
        NSLog(@"[%@ %@] recv %lu bytes",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd),
              (unsigned long)[queryHTMLResultsPage length]);
    
    //get a parser for it
    TFHpple  *resultPageParser = [[TFHpple alloc] initWithHTMLData:queryHTMLResultsPage];
        
    //get number of total search results
    NSString *numberOfResultsXpathQueryString = @"//div[@class='content']/span[@id='ctl00_ctl00_Content_Content_List01_labelSearchResultInfo']/b";
    NSArray *numberOfResultsNode = [resultPageParser searchWithXPathQuery:numberOfResultsXpathQueryString];
    
    long numberOfResults         = [numberOfResultsNode count] != 0 ?
                                   [[[numberOfResultsNode objectAtIndex:0] text] longLongValue] : 0;
    long numberOfResultsPages    = numberOfResults / RESULTS_PER_PAGE;
    
    if (SMILEY_DEBUG)
        NSLog(@"[%@ %@] parsed %ld",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd),
              numberOfResults );
    
    //get all the search results on the page
    if(numberOfResults > 0){
        
        NSString        *resultsXpathQueryString = @"//table[@class='resultTable']/tr";
        NSArray         *resultsNodes            = [resultPageParser searchWithXPathQuery:resultsXpathQueryString];
        NSMutableArray  *results                 = [[NSMutableArray alloc] init];
        
        for(TFHppleElement *element in resultsNodes)
        {
            SmileyReport* report = [[SmileyReport alloc] init];
            if([[element.children[0] objectForKey:@"class"] isEqualToString: @"Cell01"])
            {
                TFHppleElement *infoCellChild = element.children[0];
                for (int i=0; i < [infoCellChild.children count]; i++)
                {
                    TFHppleElement *currentChild = (TFHppleElement*) infoCellChild.children[i];
                    if([currentChild.tagName isEqualToString:@"div"]){
                        if( i == 0 )
                            report.companyName = [currentChild text];
                        if( i == 1 ){
                            report.address            = [[NSMutableDictionary alloc] init];
                            report.address[@"street"] = [currentChild text];
                        }
                        if( i == 2 ){
                            report.address[@"postalCode"] = [[currentChild text] substringToIndex:4] ;
                            report.address[@"city"] = [[currentChild text] substringFromIndex:4];
                        }
                    }
                }// end company name, address gathering
            }//end infoCell
            for(int i = 2 ; i < 12; i++ )
            {
                NSString* elementTitle = (NSString*)[element.children[i] objectForKey: @"title"];
                if(elementTitle)
                {
                    NSArray*  temp         = [[elementTitle componentsSeparatedByString:@"."][0] componentsSeparatedByString:@":"];
                    NSRange   subRange     = NSMakeRange([(NSString*)temp[0] length] - 10, 10);
                    NSString* date         = [(NSString*)temp[0] substringWithRange:subRange];
                    NSString* smiley       = [temp[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString* pdfURLString = @"";
                    
                    TFHppleElement *reportCellChild = ((TFHppleElement*)(element.children[i])).children[0];
                    if([reportCellChild.tagName isEqualToString:@"a"]){
                        pdfURLString = [pdfURLString stringByAppendingString:[reportCellChild objectForKey:@"href"]];
                    }
                    [report addInspectionAtDate:date withResult:smiley moreDetailsAt: pdfURLString];
                }
            }
            [results addObject:report];
            if(!allResultsMode)
                break; //return just the first matching place
        }
        return results;
    }
    return @[[[SmileyReport alloc] init]]; //one empty report object
}

+ (NSArray *)searchByPlaceName:(NSString *)placeName
{
    NSDictionary* queryParameters = @{@"searchstring": [placeName description],
                                      @"type": @"detail",
                                      @"display":@"table",
                                      @"SearchExact" :@"false",
                                      @"pagesz": @RESULTS_PER_PAGE}; // 10, 25, 50, 100, 1000
                                      
    return [FindSmileyFetcher executeCrawlerQuery:queryParameters returnAllResults:NO];

}

+ (NSArray*) searchBySmileyReportPlace:(SmileyReportPlace*) place
{
    NSDictionary* queryParameters = @{@"searchstring": [place.name description],
                                      @"address" :     [place.location[@"address"] description],
                                      @"post" :        [place.location[@"postalCode"] description],
                                      @"city" :        [place.location[@"city"] description],
                                      
                                      @"type": @"detail",
                                      @"display":@"table",
                                      @"SearchExact" :@"false",
                                      @"pagesz": @RESULTS_PER_PAGE}; // 10, 25, 50, 100, 1000
    
    return [FindSmileyFetcher executeCrawlerQuery:queryParameters returnAllResults:NO];
}

//TODO: make more consistent
+ (NSArray*) searchBySmileyReportPlaces:(NSArray*) places
{
    NSMutableArray* reports = [[NSMutableArray alloc] init];
    for(SmileyReportPlace* place in places){
        NSArray* searchResults = [[self class] searchBySmileyReportPlace: place];
        if([searchResults count] > 0){
            [reports addObject: searchResults[0]];
            place.report = searchResults[0];
        }
    }
    return reports;
}

@end
