//
//  RecentPhotoExplorerTVC.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "RecentPhotoExplorerTVC.h"
#import "RecentPhotoHistory.h"
@interface RecentPhotoExplorerTVC ()

@end

@implementation RecentPhotoExplorerTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.flickrPhotos = [RecentPhotoHistory getLatestEntries];
}

@end
