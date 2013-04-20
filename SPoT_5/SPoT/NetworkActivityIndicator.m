//
//  NetworkActivityIndicator.m
//  SPoT_4
//
//  Created by Corneliu on 4/19/13.
//  Copyright (c) 2013 Corneliu. All rights reserved.
//

#import "NetworkActivityIndicator.h"
@interface NetworkActivityIndicator()
@property (nonatomic) NSUInteger counter;
@end

@implementation NetworkActivityIndicator

static NetworkActivityIndicator *indicatorInstance;

// The runtime sends initialize to each class in a program exactly one time just before the class,
// or any class that inherits from it is sent its first message from within the program.
// The runtime sends the initialize message to classes in a thread-safe manner.
+ (void) initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        indicatorInstance = [[NetworkActivityIndicator alloc] init];
    }
}

+ (void) push
{   @synchronized(indicatorInstance){
        if(indicatorInstance.counter == 0)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        indicatorInstance.counter ++;
        NSLog(@"Counter pushed %d", indicatorInstance.counter);
    }
}

+ (void) pop
{   @synchronized(indicatorInstance){
        indicatorInstance.counter --;
        if(indicatorInstance.counter == 0)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"Counter poped %d", indicatorInstance.counter);
    }
}
@end
