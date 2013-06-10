//
//  SmileyInspectionCell.h
//  SmileyReport
//
//  Created by Corneliu on 6/2/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmileyInspectionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView    *inspectionSmileyImage;
@property (weak, nonatomic) IBOutlet UILabel        *inspectionDate;

@end
