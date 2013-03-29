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



@interface SetGameViewController ()

@end

@implementation SetGameViewController



//RGB color macro with alpha


-(SetCardDeck*) deck
{
    return [[SetCardDeck alloc] init];
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

- (void ) updateCardButton:(UIButton*)cardButton withCard:(Card*)card
{
    
    [cardButton setAttributedTitle:[self getAttributedStringForCard:card] forState:UIControlStateNormal];
    [cardButton setAttributedTitle:[self getAttributedStringForCard:card] forState:UIControlStateSelected];
    [cardButton setAttributedTitle:[self getAttributedStringForCard:card] forState:UIControlStateSelected|UIControlStateDisabled];
    
    cardButton.selected = card.isFaceUp;
    cardButton.enabled  = !card.isUnplayable;
    cardButton.backgroundColor = (!card.isFaceUp ? [UIColor whiteColor] : [UIColor grayColor]);
    
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

- (BOOL) getGameMatchingMode
{
    return YES;//yes a three card game
}

@end
