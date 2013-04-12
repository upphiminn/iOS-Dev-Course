//
//  RecentPhotoHistory.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "RecentPhotoHistory.h"
#define RECENTLY_VIEWED_PHOTOS_KEY @"RecentlyViewedPhotos"
#define MAX_RECENT_CACHE_SIZE 15

@implementation RecentPhotoHistory

+ (NSArray *)getLatestEntries
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENTLY_VIEWED_PHOTOS_KEY];
}

+ (void)addEntryToHistory:(NSDictionary *)photo
{
    NSMutableArray *recentSeenPhotos = [[[NSUserDefaults standardUserDefaults] objectForKey:RECENTLY_VIEWED_PHOTOS_KEY] mutableCopy];
    if (recentSeenPhotos){
        NSSet* photos = [[NSSet alloc] initWithArray:recentSeenPhotos];
        if([photos containsObject:photo])
            [recentSeenPhotos removeObject:photo];
        [recentSeenPhotos insertObject:photo atIndex:0];
    }
    else{
        recentSeenPhotos = [[NSMutableArray alloc] init];
        [recentSeenPhotos addObject:photo];
    }
    
    if([recentSeenPhotos count] > MAX_RECENT_CACHE_SIZE){
        [recentSeenPhotos removeLastObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:recentSeenPhotos forKey:RECENTLY_VIEWED_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
