//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Corneliu
//
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface CardMatchingGame : NSObject

//designated initializer
- (id) initWithCardCount:(NSUInteger)   count
               usingDeck:(Deck*)        deck
         andMatchingMode:(BOOL)   matchingMode;

- (void) flipCardAtIndex:(NSUInteger)   index;
- (Card*)    cardAtIndex:(NSUInteger)   index;
- (void)   resetWithDeck:(Deck *)       deck;

@property (readonly, nonatomic) int         score;
@property (readonly, nonatomic) NSMutableDictionary*   gameHistory;
@property (nonatomic)           BOOL        threeCardMatchingMode;

@end
