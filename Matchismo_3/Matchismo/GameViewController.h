//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Corneliu on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Card.h"

@interface GameViewController : UIViewController

//abstract
-(Deck*) deck;
-(BOOL) getGameMatchingMode;
-(void) updateCell:(UICollectionViewCell*) cell usingCard: (Card*) card;
//end of abstract methods

- (void)                addNewCardsToGame:(NSUInteger) number;
- (BOOL)                isGameDeckEmpty;
- (NSDictionary*)       getGameHistory;
- (IBAction)            resetGame:(UIButton *)sender;

@property (weak, nonatomic)     IBOutlet UILabel    *gameHistory;
@property (nonatomic)           NSUInteger          startingCardCount;
@property (nonatomic)           BOOL                removeUnplayableCards;

@end
