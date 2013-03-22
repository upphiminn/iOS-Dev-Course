//
//  PlayingCard.m
//  Matchismo
//
//  Created by Corneliu
//
//

#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit;

+ (NSArray *) validSuits
{
    return @[@"♥",@"♦",@"♠",@"♣"];
}

+ (NSArray *) rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSUInteger)maxRank
{
    return [self rankStrings].count-1;
}

- (NSString*)contents
{
    NSArray *rankStrings = [PlayingCard rankStrings];
    return [rankStrings[self.rank] stringByAppendingString:self.suit ];    
}

- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

-(NSString *)suit
{
    return _suit ? _suit :@"?";
}

- (void)setRank:(NSUInteger)rank
{
    if (rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    if([otherCards count] == 1){
        PlayingCard* card = [otherCards lastObject];
        if ([card.suit isEqualToString: self.suit ]){
            score = 1;
        }
        else if(card.rank == self.rank){
            score = 4;
        }
        
    }
    if([otherCards count] == 2){
        PlayingCard *firstCard = [otherCards objectAtIndex:0];
        PlayingCard *secondCard = [otherCards objectAtIndex:1];
        
        if(([firstCard.suit isEqualToString: self.suit]) &&
           ([secondCard.suit isEqualToString: self.suit])){
            score = 3;
        }
        else if((firstCard.rank == self.rank) &&
                (secondCard.rank == self.rank)){
            score = 12;
        }
    }
    return score;
}

@end
