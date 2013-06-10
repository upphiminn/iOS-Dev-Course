//
//  ForesquareFetcher.h
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface ForesquareFetcher : NSObject

+ (NSDictionary*) searchByPlaceName:(NSString*) locationName;
+ (NSDictionary*) searchWithinRegion:(CLRegion*) region;
+ (NSDictionary*) searchInVicinityOf:(CLLocationCoordinate2D)point withRadius:(NSNumber*) radiusMeters;

@end
