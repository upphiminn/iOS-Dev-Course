//
//  Deck.h
//  Matchismo
//
//  Created by Corneliu
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

- (void)    addCard:(Card *)card atTop:(BOOL) atTop;
- (Card *)  drawRandomCard;

@end
