//
//  SetCard.m
//  Matchismo
//
//  Created by Corneliu on 3/16/13.
//
//

#import "SetCard.h"
#define SEPARATOR @""

@implementation SetCard

@synthesize shading = _shading;
@synthesize color   = _color;
@synthesize symbol  = _symbol;
@synthesize repeat  = _repeat;

+ (NSArray *)validSymbols{
    return @[@"●",@"■",@"▲"];
}

+ (NSString *)SetRedColor
{
    return @"Red";
}
+ (NSString *)SetBlueColor
{
    return @"Blue";
}
+ (NSString *)SetGreenColor
{
    return @"Green";
}

+ (NSArray *)validColors
{
    return @[ [self SetRedColor], [self SetBlueColor], [self SetGreenColor]];
}


+ (NSString *)SetOpenShading
{
    return @"Open";
}
+ (NSString *)SetStrippedShading
{
    return @"Stripped";
}
+ (NSString *)SetSolidShading
{
    return @"Solid";
}


+ (NSArray *)validShadings
{
    return @[[self SetOpenShading], [self SetStrippedShading], [self SetSolidShading]];
}

+ (int)minRepeat
{
    return 1;
}

+ (int)maxRepeat
{
    return 3;
}


-(NSString *)shading
{
    return _shading ? _shading :@"?";
}

-(NSString *)color
{
    return _color ? _color :@"?";
}

-(NSString *)symbol
{
    return _symbol ? _symbol :@"?";
}

-(NSNumber*)repeat
{
    return _repeat ? _repeat :@(0);
}

-(void) setShading:(NSString *)shading
{
    if ([[SetCard validShadings] containsObject:shading]) {
        _shading = shading;
    }
}
-(void) setColor:(NSString *)color
{
    if ([[SetCard validColors] containsObject:color]) {
        _color = color;
    }
}
-(void) setSymbol:(NSString *)symbol
{
    if ([[SetCard validSymbols] containsObject:symbol]) {
        _symbol = symbol;
    }
}
-(void) setRepeat:(NSNumber *)repeat
{
    if (([repeat integerValue] >= [SetCard minRepeat]) && ([repeat integerValue]<= [SetCard maxRepeat])) {
        _repeat = repeat;
    }
}
- (int)match:(NSArray *)otherCards
{
    int score = 0;
    if([otherCards count] == 2)
     if(([otherCards[0] isKindOfClass:[SetCard class]])&&
        ([otherCards[1]  isKindOfClass:[SetCard class]]))
     {
        NSArray* cards = [otherCards arrayByAddingObject:self];
        NSMutableDictionary* colors = [NSMutableDictionary dictionary],
        *shadings   = [NSMutableDictionary dictionary],
        *symbols    = [NSMutableDictionary dictionary],
        *repeats    = [NSMutableDictionary dictionary];
        
        /*
         This would have taken a few lines in python. Was optimistic I would avoid 
         messy conditionals by counting the exact unique number of features in a match
         candidate. And applying the following logic from wikipedia
         
         The rules of Set are summarized by:
            If you can sort a group of three cards into "Two of ____ and one of _____," then it is not a set."
            
         http://en.wikipedia.org/wiki/Set_game
         */
        for(SetCard* card in cards){
            if([colors objectForKey:card.color]){
                int new_value = [(NSNumber*)[colors objectForKey:card.color] intValue] + 1;
                [colors setObject:@(new_value) forKey:card.color];
            }
            else{
                [colors setObject:@(1) forKey:card.color];
            }
            
            if([shadings objectForKey:card.shading]){
                int new_value = [(NSNumber*)[shadings objectForKey:card.shading] intValue] + 1;
                [shadings setObject:@(new_value) forKey:card.shading];
            }
            else{
                [shadings setObject:@(1) forKey:card.shading];
            }
            
            if([symbols objectForKey:card.symbol]){
                int new_value = [(NSNumber*)[symbols objectForKey:card.symbol] intValue] + 1;
                [symbols setObject:@(new_value) forKey:card.symbol];
            }
            else{
                [symbols setObject:@(1) forKey:card.symbol];
            }
            
            if([repeats objectForKey:card.repeat]){
                int new_value = [(NSNumber*)[repeats objectForKey:card.color] intValue] + 1;
                [repeats setObject:@(new_value) forKey:card.repeat];
            }
            else{
                [repeats setObject:@(1) forKey:card.repeat];
            }
            
        }
        
        if(([colors count] == 2)  || ([shadings count]==2) ||
           ([symbols count] == 2) || ([repeats count] == 2)){
            if(([colors count] == 1)  || ([shadings count]== 1) ||
               ([symbols count] == 1) || ([repeats count] == 1))
                score = 0;
        }
        else{
            score = 10;
        }
    }
    return score;
}
- (NSString*)contents
{
    
   // NSArray* content = @[self.symbol, self.repeat,self.color,self.shading];
    NSMutableArray *content = [[NSMutableArray alloc] init];
    for (int i=0; i < [self.repeat integerValue]; i++) {
        [content addObject:self.symbol];
    }
    
    return [content componentsJoinedByString:SEPARATOR];    
}


@end
