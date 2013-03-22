//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Corneliu
//
//

#import "CardMatchingGame.h"
#import "Card.h"
#import "Deck.h"


@interface CardMatchingGame()

@property (nonatomic)           int             score;
@property (strong, nonatomic)   NSMutableArray* cards; //of Cards
@property (strong, nonatomic)   NSString*       gameHistory;

-(void)         setCardPlayableStateForCards:(NSArray*) cards withDesiredState:(BOOL) state;
-(void)         setCardFlipStateForCards    :(NSArray*) cards withDesiredState:(BOOL) state;
-(void)         matchCard                   :(Card*) card;

+(NSString*)    getContentsForCards         :(NSArray*) cards;

@end


@implementation CardMatchingGame

#define MATCHBONUS  4
#define MISMATCH    2
#define FLIPCOST    1

-(NSMutableArray*) cards
{
    return _cards ? _cards : (_cards = [[NSMutableArray alloc] init]);
}

- (int) score
{
    if (!_score) _score = 0;
    return _score;
}

- (Card *) cardAtIndex:(NSUInteger)index
{
    if(index < self.cards.count)
        return self.cards[index];
    return nil;
}

- (NSArray*) getAllCardsFacingUp
{
    NSMutableArray* cardsFacingUp = [[NSMutableArray alloc] init];
    for(Card *card in self.cards){
        if(card.isFaceUp && !card.isUnplayable){
            [cardsFacingUp addObject:card];
        }
    }
    return cardsFacingUp;
}

- (void) setCardPlayableStateForCards:(NSArray*) cards withDesiredState:(BOOL) state
{
    if(cards.count > 0){
        for(Card* card in cards)
            card.unplayable = !state;
    }
}

- (void) setCardFlipStateForCards:(NSArray*) cards withDesiredState:(BOOL) state
{
    if(cards.count > 0){
        for(Card* card in cards)
            card.faceUp = state;
    }
}

+ (NSString*) getContentsForCards:(NSArray*) cards
{
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    for(Card* card in cards){
        [contents addObject:[card contents]];
    }
    return [contents componentsJoinedByString:@" | "];
}

- (void) matchCard:(Card*) card
{
    NSArray  *otherCards = [self getAllCardsFacingUp];
    if((self.threeCardMatchingMode && [otherCards count] == 2)||
      (!self.threeCardMatchingMode && [otherCards count] == 1)){
            NSString *otherCardsContents = [[self class] getContentsForCards:otherCards];
            int matchScore = [card match:otherCards];
            if(matchScore){
                [self setCardPlayableStateForCards: otherCards withDesiredState:NO];
                card.unplayable  = YES;
                self.score      += matchScore * MATCHBONUS;
                self.gameHistory = [NSString stringWithFormat:@"Match! %d, Cards: %@ | %@ ",matchScore * MATCHBONUS, card.contents, otherCardsContents];
            }
            else{
                [self setCardFlipStateForCards: otherCards withDesiredState:NO];
                self.score      -= MISMATCH;
                self.gameHistory = [NSString stringWithFormat:@"Mismatch! %d, Cards: %@ | %@ ",-MISMATCH, card.contents , otherCardsContents];
            }
    }
    self.score -= FLIPCOST;
}

- (void)flipCardAtIndex:(NSUInteger)index
{
    Card* card       = [self cardAtIndex:index];
    self.gameHistory = [NSString stringWithFormat:@"Flipped card: %@ ", card.contents];
    if (card && !card.isUnplayable){
        if (!card.isFaceUp){
            [self matchCard:card];
        }
        card.faceUp = !card.isFaceUp;
  }
}

-(void) resetWithDeck:(Deck *) deck
{
    for( int i = 0; i < self.cards.count; i++){
        Card* card = [deck drawRandomCard];
        if(card)
            self.cards[i] = card;
    }
    self.score = 0;
    self.gameHistory = @"Freshly dealt cards!";
}

-(id) initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck andMatchingMode:(BOOL) matchingMode
{
    self = [super init];
    
    if(self){
        for( int i = 0; i < count; i++){
            Card* card = [deck drawRandomCard];
            if(card){
                self.cards[i] = card;
            } else {
                self = nil;
                break;
            }
        }
        self.threeCardMatchingMode = matchingMode;
    }
    
    return self;
}

@end
