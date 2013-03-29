//
//  Card.h
//  Matchismo
//
//  Created by Corneliu
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property   (strong,nonatomic) NSString* contents;
@property   (nonatomic, getter = isFaceUp)  BOOL    faceUp;
@property   (nonatomic, getter = isUnplayable) BOOL unplayable;

-(int) match:(NSArray*) otherCards;

@end
