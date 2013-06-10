//
//  SmileyReportPlace.h
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "SmileyReport.h"

@interface SmileyReportPlace : NSObject <MKAnnotation>


@property (strong, nonatomic) NSString*     name;
@property (strong, nonatomic) NSString*     placeId;
@property (strong, nonatomic) NSDictionary* location;
@property (strong, nonatomic) SmileyReport* report;
@property (strong, nonatomic) UIImage*      categoryIcon;

- (CLLocationCoordinate2D) coordinate;
- (id)  initWithPlaceData:      (NSDictionary*) placeData;
- (id)  initFromPropertyList:   (id)            plist;
- (id)  asPropertyList;

+ (NSArray*) MakeFromDictArray: (NSArray*)      data;

@end
