//
//  FindSmileyFetcher.h
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SmileyReportPlace.h"

@interface FindSmileyFetcher : NSObject

+ (NSDictionary*) searchByPlaceName:(NSString*) placeName;
+ (NSArray*)      searchBySmileyReportPlace:(SmileyReportPlace*) place;
+ (NSArray*)      searchBySmileyReportPlaces:(NSArray*) places;
+ (NSArray*)      searchBySmileyReportPlace:(SmileyReportPlace*) place withinRegion:(CLRegion*) region;

@end
