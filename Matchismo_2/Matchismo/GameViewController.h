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

-(Deck*) deck;
-(void) updateCardButton:(UIButton*) button withCard:(Card*) card;
-(NSAttributedString*) getAttributedStringForGameHistory:(NSDictionary*) string;
//-(BOOL) getGameMatchingMode;

@end
