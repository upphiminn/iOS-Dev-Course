 //
//  CardGameViewController.m
//  Matchismo
//
//  Created by Corneliu
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCard.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"
#import "PlayingCardView.h"
#import "PlayingCardCollectionViewCell.h"
@interface CardGameViewController ()

@end


@implementation CardGameViewController


#define PLAYABLE_ALPHA      1
#define UNPLAYABLE_ALPHA    0.2

-(PlayingCardDeck*) deck
{
    return [[PlayingCardDeck alloc] init];
}

- (NSUInteger)startingCardCount
{
    return 22;
}

- (void) updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card
{
    if([cell isKindOfClass:[PlayingCardCollectionViewCell class]]){
        
        PlayingCardView* playingCardView = ((PlayingCardCollectionViewCell*)cell).playingCardView;
        if([card isKindOfClass:[PlayingCard class]]){
            
            PlayingCard* playingCard    = (PlayingCard*)card;
            playingCardView.rank        = playingCard.rank;
            playingCardView.suit        = playingCard.suit;
            playingCardView.faceUp      = playingCard.faceUp;
            playingCardView.alpha       = (playingCard.isUnplayable ? UNPLAYABLE_ALPHA : PLAYABLE_ALPHA);
        }
            
    }
}

- (void) setGameHistory
{
    if(self.gameHistory){
        //center everything
        NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
        [mutParaStyle setAlignment:NSTextAlignmentCenter];
        NSMutableAttributedString* attributedHistory = [[self getAttributedStringForGameHistory: [self getGameHistory]] mutableCopy];
        [attributedHistory addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:NSMakeRange(0, [attributedHistory length])];
        
        self.gameHistory.attributedText = attributedHistory;
    }
    else
        self.gameHistory.text = @"Game History";
}

- (NSAttributedString *) getAttributedStringForGameHistory:(NSDictionary *) history
{
    NSString* action        = [history objectForKey:@"action"];
    NSString* action_score  = [history objectForKey:@"action_score"];
    NSArray* cards          = [history objectForKey:@"card_objects"];
    NSMutableArray* output  = [[NSMutableArray alloc] initWithArray:@[action,action_score]];
    
    for( Card* c in cards){
        [output addObject:[c contents]];
    }

    return [[NSAttributedString alloc] initWithString:[output componentsJoinedByString:@", "]];
    
}
- (BOOL) getGameMatchingMode
{
    return NO;//not a threecard game
}
@end
