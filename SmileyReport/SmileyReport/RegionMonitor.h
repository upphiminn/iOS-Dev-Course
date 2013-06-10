//
//  RegionMonitor.h
//  SmileyReport
//
//  Created by Corneliu on 6/5/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SmileyReportPlace.h"
@interface RegionMonitor : NSObject

@property (strong, nonatomic) NSNumber*          alertThreshold;
@property (strong, nonatomic) NSMutableArray*       alertPlaces;
@property (strong, nonatomic) NSNumber*             regionRadius;
@property (strong, nonatomic)   CLLocationManager* locationManager;

+ (void) addAlertRegionForPlace:    (SmileyReportPlace*)    place;
+ (void) addAlertRegionForPlaces:   (NSArray*)              places;
+ (void) clear;
+ (void) setAlertThreshold:         (NSNumber *)            alertThreshold;
+ (void) setRegionRadius:           (NSNumber *)            r;
+ (void) setLocationManager:        (CLLocationManager*)    lm;
@end
