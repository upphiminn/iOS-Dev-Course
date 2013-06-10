//
//  SmileyReport.h
//  SmileyReport
//
//  Created by Corneliu on 5/26/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmileyReport : NSObject

@property (strong, nonatomic) NSString*             companyName;
@property (strong, nonatomic) NSString*             companyId;
@property (strong, nonatomic) NSMutableDictionary*  address;          //street, postalcode, city
@property (strong, nonatomic) NSMutableArray*       inspections;      //array of dicts with keys: date, result, link to pdf

- (void) addInspectionAtDate:(NSString*) date withResult:(NSString*) result moreDetailsAt:(NSString*) url;
- (NSDictionary*) getLastInspection;

- (id) initFromPropertyList:(id) plist;
- (id) asPropertyList;
- (BOOL)isEmpty;

@end
