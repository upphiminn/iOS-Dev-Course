//
//  SetGameViewController.m
//  Matchismo
//
//  Created by Corneliu on 3/16/13.
//
//

#import "SetGameViewController.h"
#import "SetCard.h"
#import "SetCardDeck.h"
#import "SetCardCollectionViewCell.h"
#import "SetCardView.h"

@interface SetGameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addCardsButton;

@end

@implementation SetGameViewController


#define PLAYABLE_ALPHA      1
#define UNPLAYABLE_ALPHA    0.2

//RGB color macro with alpha


-(SetCardDeck*) deck
{
    return [[SetCardDeck alloc] init];
}

- (BOOL) getGameMatchingMode
{
    return YES;//yes a three card game
}

- (BOOL) removeUnplayableCards
{
    return YES;
}

- (NSUInteger)startingCardCount{
    return 12;
}

- (IBAction)resetGame:(UIButton *)sender {
    [super resetGame:sender];
    self.addCardsButton.enabled = YES;
    self.addCardsButton.alpha = 1;
    [self.addCardsButton setNeedsDisplay];
}

- (IBAction)addNewCards:(id)sender {
    if([super isGameDeckEmpty] == NO){
        [self addNewCardsToGame:3];
    }
    else{
        self.addCardsButton.enabled = NO;
        self.addCardsButton.alpha = 0.2;
    }
    [self.addCardsButton setNeedsDisplay];
}
-(UIColor*) getColorForCard:(SetCard*) card
{
    UIColor* result;
    if([card.color isEqualToString: [[card class] SetRedColor]])
        result = [UIColor redColor];
    if([card.color isEqualToString: [[card class] SetBlueColor]])
        result = [UIColor blueColor];
    if([card.color isEqualToString: [[card class] SetGreenColor]])
        result = [UIColor greenColor];
    return result;
}

-(UIColor*) getShadingForCard:(SetCard*) card
{
    UIColor* result;
    result = [self getColorForCard:card];
    if([card.shading isEqualToString: [[card class] SetOpenShading]])
        result = [result colorWithAlphaComponent:0.0];
    if([card.shading isEqualToString: [[card class] SetSolidShading]])
        result = [result colorWithAlphaComponent:1.0];
    if([card.shading isEqualToString: [[card class] SetStrippedShading]])
        result = [result colorWithAlphaComponent:0.5];
    return result;
}


-(NSAttributedString*) getAttributedStringForCard:(Card*) card
{
    if([card isKindOfClass:[SetCard class]]){
        NSDictionary *attr = @{NSForegroundColorAttributeName: [self getShadingForCard:(SetCard*)card],
                               NSStrokeColorAttributeName:     [self getColorForCard:(SetCard*)card],
                               NSStrokeWidthAttributeName:      @-12,
                              };
        NSMutableAttributedString* cardContents = [[NSMutableAttributedString alloc] initWithString:[@"  " stringByAppendingString: [card contents]] attributes:attr] ;
        return cardContents;
    }
    return nil;
}

- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card
{
    if ([cell isKindOfClass:[SetCardCollectionViewCell class]]) {
        SetCardView* setCardView = ((SetCardCollectionViewCell*)cell).setCardView;
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard    = (SetCard *)card;
            setCardView.color   = setCard.color;
            setCardView.symbol  = setCard.symbol;
            setCardView.shading = setCard.shading;
            setCardView.repeat  = setCard.repeat;
            setCardView.faceUp  = setCard.isFaceUp;
            setCardView.alpha   = setCard.isUnplayable ? 0.3 : 1.0;
        }
    }

}

- (NSAttributedString *) getAttributedStringForGameHistory:(NSDictionary *)history
{
    NSArray*        cards             = [history objectForKey:@"card_objects"];
    NSArray*        action            = @[[history objectForKey:@"action"],
                                          [history objectForKey:@"action_score"]];
    NSString*       actionDescription = [action componentsJoinedByString:@" | "];
    NSMutableAttributedString* output = [[NSMutableAttributedString alloc] initWithString:actionDescription];
    
    for( Card* card in cards){
        [output insertAttributedString:[self getAttributedStringForCard:card]
                               atIndex:[output length]];
    }
    
    return output;
}

- (void)addSetCard:(SetCard *)setCard atPosition:(CGFloat)x
{
    SetCardView *setCardView = [[SetCardView alloc] initWithFrame:CGRectMake(x, 0, 66, 30)];
    setCardView.color           = setCard.color;
    setCardView.symbol          = setCard.symbol;
    setCardView.shading         = setCard.shading;
    setCardView.repeat          = setCard.repeat;
    setCardView.backgroundColor = [UIColor clearColor];
    [self.gameHistory addSubview:setCardView];
}

- (void)setGameHistory
{
    NSDictionary*   history              = [self getGameHistory];
    NSArray*        setCards             = [history objectForKey:@"card_objects"];
    NSArray*        action               = @[[history objectForKey:@"action"],
                                            [history objectForKey:@"action_score"]];
    NSString*       actionDescription    = [action componentsJoinedByString:@" | "];
    
    self.gameHistory.text = actionDescription;
    CGFloat x = [self.gameHistory.text sizeWithFont:self.gameHistory.font].width;
    
    //clear if we have any old subviews
    for (UIView *view in self.gameHistory.subviews) {
        [view removeFromSuperview];
    }
    
    //add new subviews of cards
    for (Card *setCard in setCards)
        if([setCard isKindOfClass:[SetCard class]]){
            [self addSetCard:(SetCard*)setCard atPosition:x];
            x += 70;// setcard view width + extra space
    }
    [self.gameHistory setNeedsDisplay];
}


@end
