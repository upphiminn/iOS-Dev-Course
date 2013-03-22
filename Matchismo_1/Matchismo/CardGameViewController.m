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
@property (weak, nonatomic)     IBOutlet UILabel    *flipsLabel;
@property (nonatomic)           int                 flipCount;
@property (strong, nonatomic)   CardMatchingGame    *game;
@property (weak, nonatomic)     IBOutlet UILabel    *scoreLabel;
@property (weak, nonatomic)     IBOutlet UILabel    *gameHistory;
@property (weak, nonatomic)     IBOutlet UISwitch   *gameModeSwitch;
@property (strong, nonatomic)   IBOutletCollection(UIButton) NSArray *cardButtons;
@end


@implementation CardGameViewController

@synthesize flipsLabel;
@synthesize flipCount = _flipCount;

#define THREE_CARD_MODE     TRUE
#define TWO_CARD_MODE       FALSE
#define PLAYABLE_ALPHA      1
#define UNPLAYABLE_ALPHA    0.2

-(CardMatchingGame*) game{
    return _game ?
           _game :
          (_game =  [[ CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                       usingDeck:[[PlayingCardDeck alloc] init]
                                                 andMatchingMode:TWO_CARD_MODE]);
}

- (void) setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [ NSString stringWithFormat:@"Flips %d", self.flipCount];
}

- (void ) updateUI
{
    //make the UI reflect the model
    for(UIButton* cardButton in self.cardButtons){
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        
        [cardButton setTitle: card.contents forState:UIControlStateSelected];
        [cardButton setTitle: card.contents forState:UIControlStateSelected|UIControlStateDisabled];
        [cardButton setImage: (!card.isFaceUp ? [UIImage imageNamed:@"boyavatar.jpg"] : nil)
                    forState: UIControlStateNormal];
        
        cardButton.selected = card.isFaceUp;
        cardButton.enabled  = !card.isUnplayable;
        cardButton.alpha    = (card.isUnplayable ? UNPLAYABLE_ALPHA : PLAYABLE_ALPHA);
    }
    self.scoreLabel.text  = [NSString stringWithFormat:@"Score: %d ",self.game.score];
    self.gameHistory.text = self.game.gameHistory;
}

-(void) setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];

}

- (IBAction)matchModeSelect:(UISwitch *)sender {
   self.game.threeCardMatchingMode = !(self.game.threeCardMatchingMode);
}

- (IBAction)resetGame:(UIButton *)sender {
    [self.game resetWithDeck:[ [PlayingCardDeck alloc] init]];
    self.flipsLabel.text        = @"Flips: 0";
    self.gameModeSwitch.enabled = YES;
    [self updateUI];
}

- (IBAction)flipCard:(UIButton *)sender {
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.gameModeSwitch.enabled = (self.gameModeSwitch.enabled ? NO : self.gameModeSwitch.enabled);
    self.flipCount++;  
    [self updateUI];
}

- (void)viewDidUnload {   
    [self setCardButtons:nil];
    [self setScoreLabel:nil];
    [self setGameHistory:nil];
    [self setGameModeSwitch:nil];
    [super viewDidUnload];
}
@end
