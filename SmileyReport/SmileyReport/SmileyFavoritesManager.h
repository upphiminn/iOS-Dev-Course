//
//  SmileyFavorites.h
//  SmileyReport
//
//  Created by Corneliu on 5/31/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmileyFavoritesManager.h"

@interface SmileyFavoritesManager : NSObject

+ (void)        addPlaceToFavoritesList:        (SmileyReportPlace*) place;
+ (void)        removePlaceFromFavoritesList:   (SmileyReportPlace*) place;
+ (NSArray*)    getFavoritesList;

@end
