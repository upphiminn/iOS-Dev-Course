//
//  PhotoCache.h
//  SPoT_4
//
//  Created by Corneliu on 4/20/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoCache : NSObject

+ (NSData*) retrieveDataForIdentifier:(NSString*)   identifier;
+ (void)    storeData                :(NSData*)     data       withIdentifier:(NSString*) identifier;
+ (BOOL)    isIdentifierInCache      :(NSString*)   identifier;

@end
