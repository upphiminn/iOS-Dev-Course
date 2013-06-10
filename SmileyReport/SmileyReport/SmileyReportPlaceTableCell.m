//
//  SmileyReportPlaceTableCell.m
//  SmileyReport
//
//  Created by Corneliu on 6/2/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "SmileyReportPlaceTableCell.h"
#import "SmileyInspectionCollectionViewCell.h"
@implementation SmileyReportPlaceTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
- (IBAction)addToFavoritesButtonTapped:(id)sender {
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SmileyInspectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InspectionCell" forIndexPath:indexPath];
    
    int smileyValue     = [self.inspections[indexPath.item][@"smiley"] integerValue];
    NSString *imageName = [NSString stringWithFormat:@"Sm%dcs.png", smileyValue];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    cell.inspectionDate.text         = [dateFormat stringFromDate: self.inspections[indexPath.item][@"date"]];
    cell.inspectionSmileyImage.image = [UIImage imageNamed:imageName];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.inspections count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
