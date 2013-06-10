//
//  RegionMonitor.m
//  SmileyReport
//
//  Created by Corneliu on 6/5/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "RegionMonitor.h"

#define MAX_ALLOWED_REGIONS_TO_MONITOR 20
#define DEFAULT_REGION_RADIUS 9

@implementation RegionMonitor

@synthesize alertThreshold = _alertThreshold;

static RegionMonitor* regionMonitorInstance;

+ (void) initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        regionMonitorInstance = [[RegionMonitor alloc] init];
    }
}

- (NSMutableArray*) alertPlaces
{
    if(!_alertPlaces)
        _alertPlaces = [[NSMutableArray alloc] init];
    return _alertPlaces;
}

- (NSNumber*) regionRadius
{
    if(!_regionRadius)
        _regionRadius = @DEFAULT_REGION_RADIUS;
    return _regionRadius;
}

+ (NSNumber*) alertThreshold
{
    return regionMonitorInstance.alertThreshold;
}

+ (void) setAlertThreshold:(NSNumber *)alertThreshold
{
    int value = [alertThreshold integerValue];
    if( value >= 0 && value <= 4) // 0 - disabled [1,4] - smiley values
        regionMonitorInstance.alertThreshold = alertThreshold;
    
}

+ (void) setRegionRadius:(NSNumber *)r
{
    int value = [r integerValue];
    if( value > 0)
        regionMonitorInstance.regionRadius = r;
}

+ (void) setLocationManager:(CLLocationManager *)lm
{
    regionMonitorInstance.locationManager = lm;
}

+ (void) addAlertRegionForPlace:(SmileyReportPlace*) place
{
    //check if geofencing available
    if ( ![CLLocationManager regionMonitoringAvailable])
        return;
    
    // Check the authorization status
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) &&
        ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined))
        return;

    int alertThreshold = [regionMonitorInstance.alertThreshold integerValue];
    if(![regionMonitorInstance.alertPlaces containsObject:place])
    if([[place.report getLastInspection][@"smiley"] integerValue] >= alertThreshold){
        //NSLog(@"Adding geo fence %d",[[place.report getLastInspection][@"smiley"] integerValue]);
                CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter: place.coordinate
                                                                   radius:[regionMonitorInstance.regionRadius doubleValue]
                                                               identifier:place.placeId];
       //NSLog(@"location manger %@", regionMonitorInstance.locationManager );
        [regionMonitorInstance.locationManager startMonitoringForRegion:region];
        [regionMonitorInstance.alertPlaces addObject:region];
        [regionMonitorInstance clearOldAlertRegions];
    }
}

+ (void) addAlertRegionForPlaces:(NSArray *)places
{
    NSLog(@"CALLLED");
    for(SmileyReportPlace* place in places) //check if we're loading new places if so we should wait; or just research nearby places
        if(place.report!=nil && ![place.report isEmpty]){
            int reportValue = [[place.report getLastInspection][@"smiley"] integerValue];
       //     NSLog(@"Report value %d", reportValue);
       //     NSLog(@"Threshold %d", [[self class].alertThreshold integerValue]);
            if (reportValue >= [[self class].alertThreshold integerValue]){
                [[self class] addAlertRegionForPlace:place];
                NSLog(@"Added alert for %@", place.name);
            }
        }
}

//stop monitoring regions and empty the alertplace array
+ (void) clear
{
    for(SmileyReportPlace* place in regionMonitorInstance.alertPlaces){
        [regionMonitorInstance.locationManager stopMonitoringForRegion:(CLRegion*)place];
    }
   // regionMonitorInstance.alertPlaces = nil;
}

// Each application is allowed only 20 regions to monitor.
// To make sure we don't overwrite a random access region
// which is also new (it's not clear how iOS deals with it, if orderly or not),
// we are playing it safe i.e. we just pop the oldest region monitor and stop monitoring for it.

- (void) clearOldAlertRegions
{
    if([regionMonitorInstance.alertPlaces count] > MAX_ALLOWED_REGIONS_TO_MONITOR){
        CLRegion* region = regionMonitorInstance.alertPlaces[0];               //oldest region
        [regionMonitorInstance.locationManager stopMonitoringForRegion:region]; //stop monitoring
        [regionMonitorInstance.alertPlaces removeObjectAtIndex:0];             //remove it
    }
    
}


@end
