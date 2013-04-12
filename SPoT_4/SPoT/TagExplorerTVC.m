//
//  TagExplorerTVC.m
//  SPoT
//
//  Created by Corneliu on 4/12/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "TagExplorerTVC.h"
#import "FlickrFetcher.h"

#define TAGS_TO_EXCLUDE @[@"cs193pspot",@"portrait", @"landscape"]

@interface TagExplorerTVC ()

@property (strong, nonatomic) NSArray*           tags;          //NSStrings
@property (strong, nonatomic) NSSet*             tagsToExclude; //NSStrings
@property (strong, nonatomic) NSDictionary*      photoHierarchyByTag;//NSDictionary with NSArrays of NSDictionaries as values (sets of photos), and NSString (tag) as key
@property (strong, nonatomic) NSArray*           flickrPhotos;

@end

@implementation TagExplorerTVC

- (NSSet*) tagsToExclude
{
    return [[NSSet alloc] initWithArray:TAGS_TO_EXCLUDE];
}

- (NSArray*) tags
{
    if(_tags){
        return _tags;
    }
    else{
        
        NSMutableSet* allTagsSet = [[FlickrFetcher getTagsForPhotos:self.flickrPhotos] mutableCopy]; //custom method
        [allTagsSet minusSet:self.tagsToExclude];
        _tags = [allTagsSet allObjects];
    }
    return _tags;
}


- (void) updatedPhotoHierarchyByTag
{
    self.photoHierarchyByTag = [FlickrFetcher groupPhotos:self.flickrPhotos
                                                   byTags:self.tags]; //custom method
}


- (void)setFlickrPhotos:(NSArray *)flickrPhotos
{
    _flickrPhotos = flickrPhotos;
    [self updatedPhotoHierarchyByTag];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flickrPhotos = [FlickrFetcher stanfordPhotos];
}

#pragma mark - Segue related things

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos With Tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setFlickrPhotos:)]) {
                    NSString *tag = [self titleForRow:indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setFlickrPhotos:)
                                                          withObject:self.photoHierarchyByTag[tag]];
                    [segue.destinationViewController setTitle:tag];
                }
            }
        }
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.tags objectAtIndex:row];
}

- (NSString *)subtitleForRow:(NSUInteger)row
{
    NSString* rowTag = [self.tags objectAtIndex:row];
    NSUInteger numOfPhotosWithTag = [[self.photoHierarchyByTag objectForKey:rowTag] count];
    return [NSString stringWithFormat:@"%d", numOfPhotosWithTag];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text       = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}


@end
