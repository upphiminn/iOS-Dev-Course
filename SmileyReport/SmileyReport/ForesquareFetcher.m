//
//  ForesquareFetcher.m
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "ForesquareFetcher.h"

#define CLIENT_SECRET       @"EDN4NDJFZHN2GK4ZEE1VEFERO3PPV5TA1C4P3QMUCKJWJZ3R"
#define CLIENT_ID           @"YG3QLJ2KHXMMZZZBVXWLB23ZFRCQVG4YKBKBAYBNIIDMYN3Z"
#define VENUE_API_BASEURL   @"https://api.foursquare.com/v2/venues/search?"
#define SMILEY_DEBUG        NO
#define CATEGORIES_ID_SET   @"4d4b7105d754a06374d81259"
#define MAX_RADIUS          @100000
//TODO: get a new FS key for this specific app

@implementation ForesquareFetcher

+ (NSDictionary*) executeAPIQuery: (NSDictionary*) parameters
{
    NSString* query = [[NSMutableString alloc] initWithString:VENUE_API_BASEURL];
    
    for(NSString* parameter in parameters){
        query = [query stringByAppendingFormat:@"&%@=%@",parameter,[parameters objectForKey:parameter]];
    }
    
    //making the v parameter
    NSDate*          today      = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString* version           = [dateFormat stringFromDate:today];
    
    //add app id, secret and version parameter
    query = [query stringByAppendingFormat:@"&client_id=%@&client_secret=%@&v=%@",
     CLIENT_ID, CLIENT_SECRET, version];
    
    //url encode
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (SMILEY_DEBUG)
        NSLog(@"[%@ %@] sent %@",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd),
              query);
    
    //make request
    NSData* jsonResponseData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query]
                                                         encoding: NSUTF8StringEncoding
                                                            error: nil]
                                dataUsingEncoding:NSUTF8StringEncoding];
    
    //parse json response
    NSDictionary* result = jsonResponseData ? [NSJSONSerialization JSONObjectWithData:jsonResponseData
                                                                              options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers
                                                                                error:nil] : nil;
    if (SMILEY_DEBUG)
        NSLog(@"[%@ %@] recv %@",
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd),
              result);
    
    return [result objectForKey:@"response"];
}


+ (NSDictionary*) searchByPlaceName:(NSString *)locationName
{
    NSDictionary* searchParameters = @{ @"near" : @"Copenhagen",
                                       @"query" : [locationName description],
                                       @"intent": @"browse"};
    
    return [ForesquareFetcher executeAPIQuery:searchParameters];
}

+ (NSDictionary *) searchInVicinityOf:(CLLocationCoordinate2D)point withRadius:(NSNumber*) radiusMeters
{
    // max allowed
    if([radiusMeters unsignedIntegerValue] > [MAX_RADIUS longValue])
        radiusMeters = MAX_RADIUS;

    NSDictionary* searchParameters = @{ @"ll"     : [NSString stringWithFormat:@"%f,%f",point.latitude, point.longitude],
                                        @"radius" : radiusMeters,
                                        @"intent" : @"browse",
                                        @"categoryId": CATEGORIES_ID_SET};
    
    return [ForesquareFetcher executeAPIQuery:searchParameters];
}
@end
