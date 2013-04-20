//
//  RecentPhotoHistory.h
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotoHistory : NSObject

+ (NSArray*)    getLatestEntries;
+ (void)        addEntryToHistory:  (NSDictionary*) photo;
@end
