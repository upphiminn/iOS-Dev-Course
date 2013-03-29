//
//  SetCard.h
//  Matchismo
//
//  Created by Corneliu on 3/16/13.
//
//

#import "Card.h"

@interface SetCard : Card

@property (strong, nonatomic)   NSString* shading;
@property (strong, nonatomic)   NSString* color;
@property (strong, nonatomic)   NSString* symbol;
@property (nonatomic)   NSNumber* repeat;

+(NSArray*)validColors;
+(NSArray*)validSymbols;
+(NSArray*)validShadings;
+(int)minRepeat;
+(int)maxRepeat;

+(NSString*)SetRedColor;
+(NSString*)SetGreenColor;
+(NSString*)SetBlueColor;

+(NSString*)SetOpenShading;
+(NSString*)SetStrippedShading;
+(NSString*)SetSolidShading;

@end
