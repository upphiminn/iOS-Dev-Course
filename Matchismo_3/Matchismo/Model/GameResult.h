//
//  GameResult.h
//  Matchismo
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameResult : NSObject

+ (NSArray *)allGameResults; // of GameResult
- initWithGameKind:(NSString*) name;
@property (readonly, nonatomic) NSDate *start;
@property (readonly, nonatomic) NSDate *end;
@property (readonly, nonatomic) NSTimeInterval duration;
@property (readonly, nonatomic) NSString *gameName;
@property (nonatomic) int score;

// added after lecture

- (NSComparisonResult)compareScoreToGameResult:(GameResult *)otherResult;
- (NSComparisonResult)compareEndDateToGameResult:(GameResult *)otherResult;
- (NSComparisonResult)compareDurationToGameResult:(GameResult *)otherResult;

@end