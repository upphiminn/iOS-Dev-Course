//
//  Deck.m
//  Matchismo
//
//  Created by Corneliu on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Deck.h"

@interface Deck()
@property   (strong, nonatomic) NSMutableArray *cards;
@end

@implementation Deck

- (NSMutableArray*) cards{
    if(!_cards)
        _cards = [[NSMutableArray alloc]init];
    return _cards;
    
}

- (BOOL) isEmpty
{
    if([self.cards count] == 0)
        return YES;
    return NO;
}

- (void) addCard:(Card *)card atTop:(BOOL)atTop{

    if(atTop) {
        [self.cards insertObject:card atIndex:0];
    }else{
        [self.cards addObject:card];
    }
    
}

- (Card *)drawRandomCard{
    Card *randomCard = nil;
    if(self.cards.count){
        unsigned index = arc4random() % self.cards.count;
        randomCard = self.cards[index];
        [self.cards removeObjectAtIndex:index];
    }
    return randomCard;
}

@end
