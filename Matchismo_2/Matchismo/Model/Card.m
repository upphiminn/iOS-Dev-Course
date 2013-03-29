//
//  Card.m
//  Matchismo
//
//  Created by Corneliu on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Card.h"

@implementation Card
- (int) match:(NSArray *)otherCards
{
      NSLog(@"MEHCARD");
    int score = 0;
    for(Card *card in otherCards)
        if([card.contents isEqualToString:self.contents]){
            score = 1;
        }
           
    return score;
}
@end
