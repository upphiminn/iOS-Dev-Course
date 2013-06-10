//
//  SmileyReportPlaceTableCell.h
//  SmileyReport
//
//  Created by Corneliu on 6/2/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmileyReportPlaceTableCell : UITableViewCell<UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView        *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel            *title;
@property (weak, nonatomic) IBOutlet UILabel            *subtitle;
@property (strong, nonatomic)        NSArray            *inspections;
@property (weak, nonatomic) IBOutlet UICollectionView   *inspectionsCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingReportsActivityIndicatorView;

@end
