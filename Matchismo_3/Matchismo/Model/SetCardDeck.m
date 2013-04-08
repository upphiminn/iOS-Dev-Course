//
//  SetCardDeck.m
//  Matchismo
//
//  Created by Corneliu on 3/16/13.
//
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (id) init
{
    self = [super init];
    if(self){
        for(NSString* color in [SetCard validColors])
            for(NSString* shading in [SetCard validShadings])
                for(NSString* symbol in [SetCard validSymbols])
                    for(int r = [SetCard minRepeat]; r<=[SetCard maxRepeat];r++)
                    {
                        SetCard* card = [[SetCard alloc] init];
                        card.color = color;
                        card.shading = shading;
                        card.symbol = symbol;
                        card.repeat = @(r);
                        [self addCard:card atTop:YES];
                        
                    }  
    }
    return self;
}
@end
