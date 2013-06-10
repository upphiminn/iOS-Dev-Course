//
//  SmileyFavorites.m
//  SmileyReport
//
//  Created by Corneliu on 5/31/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "SmileyReportPlace.h"

#define FAVORITES_KEY @"SmileyReportFavorites_All"

@implementation SmileyFavoritesManager

+ (void)addPlaceToFavoritesList:(SmileyReportPlace *)place
{
   NSMutableDictionary *mutableFavoritesFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITES_KEY] mutableCopy];
   if (!mutableFavoritesFromUserDefaults)
       mutableFavoritesFromUserDefaults = [[NSMutableDictionary alloc] init];
    mutableFavoritesFromUserDefaults[place.placeId] = [place asPropertyList];
    [[NSUserDefaults standardUserDefaults] setObject:mutableFavoritesFromUserDefaults forKey:FAVORITES_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removePlaceFromFavoritesList:(SmileyReportPlace *)place
{
    NSMutableDictionary *mutableFavoritesFromUserDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITES_KEY] mutableCopy];
    if (!mutableFavoritesFromUserDefaults)
        return;
    [mutableFavoritesFromUserDefaults removeObjectForKey:place.placeId];
    [[NSUserDefaults standardUserDefaults] setObject:mutableFavoritesFromUserDefaults forKey:FAVORITES_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getFavoritesList
{
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    
    for (id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:FAVORITES_KEY] allValues]) {
        SmileyReportPlace *result = [[SmileyReportPlace alloc] initFromPropertyList:plist];
        [favorites addObject:result];
    }
    
    [favorites sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SmileyReportPlace* obj_1 = (SmileyReportPlace*) obj1;
        SmileyReportPlace* obj_2 = (SmileyReportPlace*) obj2;
        return [obj_1.name compare:obj_2.name];
    }];
    
    return favorites;
}
@end
