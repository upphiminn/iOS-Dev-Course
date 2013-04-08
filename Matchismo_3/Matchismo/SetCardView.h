//
//  SetCardView.h
//  Matchismo_3
//
//  Created by Corneliu on 4/5/13.
//
//

#import <UIKit/UIKit.h>

@interface SetCardView : UIView

@property (strong, nonatomic)   NSString* shading;
@property (strong, nonatomic)   NSString* color;
@property (strong, nonatomic)   NSString* symbol;
@property (strong, nonatomic)   NSNumber* repeat;
@property (nonatomic)           BOOL      faceUp;

@end
