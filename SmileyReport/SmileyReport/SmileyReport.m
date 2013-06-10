//
//  SmileyReport.m
//  SmileyReport
//
//  Created by Corneliu on 5/26/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "SmileyReport.h"
@interface SmileyReport()

@end

@implementation SmileyReport

- (NSMutableArray*)inspections
{
    if(!_inspections)
        _inspections = [[NSMutableArray alloc] init];
    
    return _inspections;
}

- (void) addInspectionAtDate:(NSString*) date withResult:(NSString*) result moreDetailsAt:(NSString*) url
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSDate    *smileyDate   = [dateFormat dateFromString:date];
    NSNumber  *smileyNumber = @([[result componentsSeparatedByString:@" "][1] intValue]);
    NSString  *smileyLink   = [NSString stringWithString:url ];
    //this original URL page contains some JS that creates weird visual artifacts
    NSString  *correctURL   = @"http://www.findsmiley.fvst.dk/templates/smiley.fvst.dk/PDFViewer/PDFViewer.aspx?";
    correctURL = [correctURL stringByAppendingString:([smileyLink componentsSeparatedByString:@"?"][1])];
    
    NSMutableDictionary *report = [[NSMutableDictionary alloc] init];
    report[@"date"]     = smileyDate;
    report[@"smiley"]   = smileyNumber;
    report[@"doc_link"] = correctURL;
    
    [self.inspections addObject:report];
}

- (NSDictionary*) getLastInspection
{
    return self.inspections[0];
}

- (NSArray*) asPropertyList
{
    return self.inspections;
}

- (id) initFromPropertyList:(id) plist
{
    self = [super init];
    if(self){
        if([plist isKindOfClass:[NSArray class]])
            self.inspections = (NSMutableArray*)[plist mutableCopy];
    }
    return self;
}

- (BOOL) isEmpty
{
    if ([self.inspections count] == 0)
        return YES;
    return NO;
}
@end
