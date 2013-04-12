//
//  PhotoExplorerTVC.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "PhotoExplorerTVC.h"
#import "FlickrFetcher.h"
#import "RecentPhotoHistory.h"
@interface PhotoExplorerTVC ()



@end

@implementation PhotoExplorerTVC


- (void)setFlickrPhotos:(NSArray *)flickrPhotos
{
    _flickrPhotos = flickrPhotos;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrPhotos count];
}

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.flickrPhotos[row][FLICKR_PHOTO_TITLE] description];
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [self.flickrPhotos[row][FLICKR_PHOTO_OWNER] description];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text       = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    return cell;
}

#pragma mark - Prepare for Segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotoURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:self.flickrPhotos[indexPath.row]
                                                     format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setPhotoURL:)
                                                          withObject:url];
                    [RecentPhotoHistory addEntryToHistory:self.flickrPhotos[indexPath.row]];
                    NSString *title = [self titleForRow:indexPath.row];
                    [segue.destinationViewController setTitle:title];
                    
                }
            }
        }
    }
}


@end
