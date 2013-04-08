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

- (void)  flipCardAtIndex:(NSUInteger)   index;
- (void)removeCardAtIndex:(NSUInteger)   index;
- (Card*)     cardAtIndex:(NSUInteger)   index;
- (void)    resetWithDeck:(Deck *)         deck   andCardCount:(NSUInteger) cardCount;
- (void)      addNewCards:(NSUInteger)   numberOfCards;
- (BOOL)  isCardDeckEmpty;


@property (nonatomic)           int numberOfCards;
@property (readonly, nonatomic) int         score;
@property (readonly, nonatomic) NSMutableDictionary*   gameHistory;
@property (nonatomic)           BOOL        threeCardMatchingMode;

@end
