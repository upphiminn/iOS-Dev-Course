//
//  SmileyReportPlace.m
//  SmileyReport
//
//  Created by Corneliu on 5/25/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "SmileyReportPlace.h"
@interface SmileyReportPlace()



@property (strong, nonatomic) UIImage* categoryThumbnail;
@end

@implementation SmileyReportPlace

- (NSString*) title
{
    return self.name;
}

- (NSString*) subtitle
{
    if(self.report == nil)
        return @"Fetching data...";
    else if([self.report isEmpty])
        return @"No data found.";
    else{
        NSDate* lastInspectionDate = [[self.report getLastInspection] objectForKey:@"date"];
        NSDateFormatter* DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"dd-MM-yyyy"];
        return [NSString stringWithFormat:@"Last Inspection: %@", [DateFormatter stringFromDate:lastInspectionDate]];
    }
    return @"No data.";
}

- (UIImage*) thumbnail
{
    return self.categoryIcon;
}

- (NSArray*) inspections
{
    if(self.report)
        return [self.report.inspections copy];
    return nil;
}

- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [self.location[@"longitude"] doubleValue];
    coordinate.latitude  = [self.location[@"latitude"]  doubleValue];
    return  coordinate;
}

- (id) initWithPlaceData:(NSDictionary *)placeData
{
    self = [super init];
    if(self){
        self.name       = placeData[@"name"];
        self.placeId    = placeData[@"id"];
        
        if(placeData[@"categories"] && placeData[@"categories"][0][@"icon"]){
            NSString* iconPrefix = (NSString*)placeData[@"categories"][0][@"icon"][@"prefix"];
            NSString* iconSuffix = (NSString*)placeData[@"categories"][0][@"icon"][@"suffix"];
            iconPrefix = [iconPrefix substringToIndex:iconPrefix.length - 1];
            
            NSString* categoryIconStringURL = [NSString stringWithFormat:@"%@%@", iconPrefix, iconSuffix];
            self.categoryIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:categoryIconStringURL]]];
        }
        if(!self.categoryIcon)
            self.categoryIcon = [UIImage imageNamed:@"unknown_category.png"];
        
        NSMutableDictionary* location   = [[NSMutableDictionary alloc] init];
        location[@"latitude"]   = placeData[@"location"][@"lat"];
        location[@"longitude"]  = placeData[@"location"][@"lng"];
        location[@"address"]    = placeData[@"location"][@"location"]  ? placeData[@"location"][@"address"]    : @"";
        location[@"city"]       = placeData[@"location"][@"city"]      ? placeData[@"location"][@"city"]       : @"";
        location[@"country"]    = placeData[@"location"][@"country"]   ? placeData[@"location"][@"country"]    : @"";
        location[@"postalCode"] = placeData[@"location"][@"postalCode"]? placeData[@"location"][@"postalCode"] : @"";
        self.location = [location copy];
    }
    return self;
}

+ (NSArray*) MakeFromDictArray:(NSArray*) data
{
    NSMutableArray* cleanVenues = [[NSMutableArray alloc] init];
    for(NSDictionary* venue in data){
        SmileyReportPlace* place = [[SmileyReportPlace alloc] initWithPlaceData:venue];
        [cleanVenues addObject:place];
    }
    return cleanVenues;
}

- (id)initFromPropertyList:(id)plist
{
    self = [self init];
    if (self) {
        if ([plist isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDictionary = (NSDictionary *)plist;
            self.name = resultDictionary[@"name"];
            self.placeId   = resultDictionary[@"placeId"];
            NSMutableDictionary* location   = [[NSMutableDictionary alloc] init];
            location[@"latitude"]  = resultDictionary[@"latitude"];
            location[@"longitude"] = resultDictionary[@"longitude"];
            self.location = [location copy];
            self.categoryIcon = [UIImage imageWithData:resultDictionary[@"categoryIcon"]];
            self.report = [[SmileyReport alloc] initFromPropertyList:resultDictionary[@"smileyReport"]];

        }
    }
    return self;
}

-(id) asPropertyList
{
    return @{ @"name" : self.name,
              @"placeId" : self.placeId,
              @"latitude" : self.location[@"latitude"],
              @"longitude" : self.location[@"longitude"],
              @"categoryIcon" : UIImagePNGRepresentation(self.categoryIcon),
              @"smileyReport" : [self.report asPropertyList]};
}


@end
