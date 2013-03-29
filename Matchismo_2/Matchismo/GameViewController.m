//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Corneliu
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "Deck.h"
#import "GameResult.h"
#import "PlayingCardDeck.h"
#import "CardMatchingGame.h"

@interface GameViewController ()
@property (weak, nonatomic)     IBOutlet UILabel    *flipsLabel;
@property (nonatomic)           int                 flipCount;
@property (strong, nonatomic)   CardMatchingGame    *game;
@property (weak, nonatomic)     IBOutlet UILabel    *scoreLabel;
@property (weak, nonatomic)     IBOutlet UILabel    *gameHistory;
@property (strong, nonatomic)   GameResult          *gameResult;
@property (strong, nonatomic)   IBOutletCollection(UIButton) NSArray *cardButtons;
@end


@implementation GameViewController

@synthesize flipsLabel;
@synthesize flipCount = _flipCount;
@synthesize gameHistory = _gameHistory;


-(CardMatchingGame*) game
{
    return _game ?
    _game :
    (_game =  [[ CardMatchingGame alloc] initWithCardCount:self.cardButtons.count
                                                 usingDeck:[self deck]
                                                 andMatchingMode: [self getGameMatchingMode]]);
}

//abstract
-(Deck*) deck
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

//abstract
-(BOOL) getGameMatchingMode
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return FALSE;
}

//abstract
- (void) updateCardButton:(UIButton *)button withCard:(Card *)card
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

//abstract
-(NSAttributedString*) getAttributedStringForGameHistory:(NSDictionary*) history
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (GameResult *)gameResult
{
    NSString* gameName = [self getGameMatchingMode] ? @"Cards" : @"Set";
    return _gameResult ? _gameResult:(_gameResult = [[GameResult alloc] initWithGameKind:gameName]);
    
}

- (void) setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [ NSString stringWithFormat:@"Flips %d", self.flipCount];
}

- (void) setGameScore:(int)gameScore
{
    self.scoreLabel.text  = [NSString stringWithFormat:@"Score: %d ",gameScore];
}


- (void) setGameHistory
{
    if(_gameHistory){
        //center everything
        NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
        [mutParaStyle setAlignment:NSTextAlignmentCenter];
        NSMutableAttributedString* attributedHistory = [[self getAttributedStringForGameHistory: self.game.gameHistory] mutableCopy];
        [attributedHistory addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:NSMakeRange(0, [attributedHistory length])];
        
        self.gameHistory.attributedText = attributedHistory;
    }
    else
        _gameHistory.text = @"Game History";
}

-(void) setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];
}

- (void ) updateUI
{
    //make the UI reflect the model
    for(UIButton* cardButton in self.cardButtons){
         Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [self updateCardButton:cardButton withCard:card];
    }
    [self setGameScore:self.game.score];
    [self setGameHistory];
}


- (IBAction)resetGame:(UIButton *)sender {
    [self.game resetWithDeck:[self deck]];
    self.flipsLabel.text        = @"Flips: 0";
    self.gameResult = nil;
    [self updateUI];
}

- (IBAction)flipCard:(UIButton *)sender
{
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipCount++;
    self.gameResult.score = self.game.score;
    [self updateUI];
}

- (void)viewDidUnload {
    [self setCardButtons:nil];
    [self setScoreLabel:nil];
    [self setGameHistory:nil];
    [super viewDidUnload];
}
@end
