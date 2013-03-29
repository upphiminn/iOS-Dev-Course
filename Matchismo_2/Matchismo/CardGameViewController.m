//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Corneliu
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CardGameViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()

@end


@implementation CardGameViewController


#define PLAYABLE_ALPHA      1
#define UNPLAYABLE_ALPHA    0.2

-(PlayingCardDeck*) deck
{
    return [[PlayingCardDeck alloc] init];
}

- (void ) updateCardButton:(UIButton*)cardButton withCard:(Card*)card
{
       
        [cardButton setTitle: card.contents forState:UIControlStateSelected];
        [cardButton setTitle: card.contents forState:UIControlStateSelected|UIControlStateDisabled];
        [cardButton setImage: (!card.isFaceUp ? [UIImage imageNamed:@"boyavatar.jpg"] : nil)
                    forState: UIControlStateNormal];
        
        cardButton.selected = card.isFaceUp;
        cardButton.enabled  = !card.isUnplayable;
        cardButton.alpha    = (card.isUnplayable ? UNPLAYABLE_ALPHA : PLAYABLE_ALPHA);

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
