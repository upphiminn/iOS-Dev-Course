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
#import "CardMatchingGame.h"

@interface GameViewController () <UICollectionViewDataSource>
@property (weak, nonatomic)     IBOutlet UILabel    *flipsLabel;
@property (nonatomic)           int                 flipCount;
@property (strong, nonatomic)   CardMatchingGame    *game;
@property (weak, nonatomic)     IBOutlet UILabel    *scoreLabel;
@property (strong, nonatomic)   GameResult          *gameResult;
@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;
@end
 

@implementation GameViewController

@synthesize flipsLabel;
@synthesize flipCount = _flipCount;
@synthesize gameHistory = _gameHistory;


-(CardMatchingGame*) game
{
    return _game ?
    _game :
    (_game =  [[ CardMatchingGame alloc] initWithCardCount:self.startingCardCount 
                                                 usingDeck:[self deck]
                                                 andMatchingMode: [self getGameMatchingMode]]);
}


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{ //ask game how many cards
    return self.game.numberOfCards;
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GameCard" forIndexPath:indexPath];
    Card *card = [self.game cardAtIndex:indexPath.item];
    [self updateCell: cell usingCard:card];
    
    return cell;
}



//abstract
- (void) updateCell:(UICollectionViewCell*) cell usingCard: (Card*) card
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
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



- (GameResult *)gameResult
{
    NSString* gameName = [self getGameMatchingMode] ? @"Cards" : @"Set";
    return _gameResult ? _gameResult:(_gameResult = [[GameResult alloc] initWithGameKind:gameName]);
    
}

- (BOOL) removeUnplayableCards
{
   return _removeUnplayableCards ? _removeUnplayableCards : (_removeUnplayableCards = NO);
}

- (void) setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [ NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (void) setGameScore:(int)gameScore
{
    self.scoreLabel.text  = [NSString stringWithFormat:@"Score: %d ",gameScore];
}


- (void) setGameHistory
{
    return;
}

- (void ) updateUI
{
    for (UICollectionViewCell* cell in [self.cardCollectionView visibleCells]){
        NSIndexPath* indexPath = [self.cardCollectionView indexPathForCell:cell];
        Card* card = [self.game cardAtIndex:indexPath.item];
        // added to remove set cards that are unplayable from the game.
        if(self.removeUnplayableCards && card.isUnplayable){
            [self.game removeCardAtIndex:indexPath.item];
            [self.cardCollectionView deleteItemsAtIndexPaths: @[indexPath]];
        }
        else
        [self updateCell:cell usingCard:card];
    }
    [self setGameScore: self.game.score];
    [self setGameHistory];
}

- (IBAction)resetGame:(UIButton *)sender {
    [self removeUnusedCards];
    [self.game resetWithDeck:[self deck] andCardCount:[self startingCardCount]];
    self.flipsLabel.text = @"Flips: 0";
    self.gameResult = nil;
    self.flipCount = 0;
    [self.cardCollectionView reloadData];
    [self updateUI];
}

- (void) removeUnusedCards
{
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    //collect all index paths for items over the initial number
    for(int i = [self startingCardCount] - 1 ; i < [self.game numberOfCards]; i++){
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [indexes addObject:indexPath];
    }
    // remove the last card, n times, we can't directly remove by index, since after removing
    // one card the indexes change. Should move this to a method inside game.
    int n = [indexes count];
    while( n > 0){
        [self.game removeCardAtIndex:[self startingCardCount] - 1];
        n--;
    }
    [self.cardCollectionView deleteItemsAtIndexPaths: indexes];
    [self.cardCollectionView reloadData];
}

- (IBAction)flipCard:(UITapGestureRecognizer*) gesture
{
    CGPoint tapLocation = [gesture locationInView:self.cardCollectionView];
    NSIndexPath* indexPath = [self.cardCollectionView indexPathForItemAtPoint:tapLocation];
    if(indexPath){
        //we can tap between cards, indexpath could be null
        [self.game flipCardAtIndex:indexPath.item];
        self.flipCount++;
        self.gameResult.score = self.game.score;
        [self updateUI];
    }
}

- (void) addNewCardsToGame:(NSUInteger) number
{
    [self.game addNewCards: number];
    [self.cardCollectionView reloadData];
    [self.cardCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(self.game.numberOfCards - 1) inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:YES];
}

- (BOOL) isGameDeckEmpty
{
   return [self.game isCardDeckEmpty];
}

- (NSDictionary*) getGameHistory
{
    return self.game.gameHistory;
}

- (void)viewDidUnload {
    [self setScoreLabel:nil];
    [self setGameHistory:nil];
    [super viewDidUnload];
}
@end
