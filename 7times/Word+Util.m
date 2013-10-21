//
// Created by Li Shuo on 13-10-9.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Word+Util.h"
#import "Check.h"
#import "SLSharedConfig.h"


@implementation Word (Util)

-(BOOL)lastCheckExpired {
    if(self.checkNumber.integerValue >= 7){
        return NO;
    }

    NSDate *lastCheckDate = self.lastCheckTime;
    if(lastCheckDate == nil){
        lastCheckDate = [NSDate dateWithTimeIntervalSince1970:0];
    }

    int shouldWaitHours = [[SLSharedConfig sharedInstance].timeIntervals[self.checkNumber.integerValue] integerValue];
    return ABS([[NSDate date] timeIntervalSinceDate:lastCheckDate]) >= shouldWaitHours * 60 * 60;
}

-(Check *)lastCheck {
    Check* c;
    NSDate *lastCheckDate = [NSDate dateWithTimeIntervalSince1970:0];
    for(Check *check in self.check){
        if([lastCheckDate compare:check.date] == NSOrderedAscending){
            lastCheckDate = check.date;
            c = check;
        }
    }

    return c;
}

+(NSComparator)comparator {
    return ^NSComparisonResult(Word *word1, Word *word2) {
        if(word2.checkNumber.integerValue == 0){
            return NSOrderedAscending;
        }

        if(word1.checkNumber.integerValue == 0){
            return NSOrderedDescending;
        }

        NSArray *timeIntervals = [SLSharedConfig sharedInstance].timeIntervals;
        int interval1 = [timeIntervals[(uint)word1.checkNumber.integerValue] integerValue];
        int interval2 = [timeIntervals[(uint)word2.checkNumber.integerValue] integerValue];

        NSDate *time1 = [word1.lastCheckTime dateByAddingTimeInterval:interval1 * 60 * 60];
        NSDate *time2 = [word2.lastCheckTime dateByAddingTimeInterval:interval2 * 60 * 60];

        return [time1 compare:time2];
    };
}

- (void)addCheckHelper:(Check *)check {
    [self addCheck:[NSSet setWithObject:check]];
    self.lastCheckTime = check.date;
    self.checkNumber = @(self.checkNumber.integerValue + 1);
    self.nextCheckTime = [check.date dateByAddingTimeInterval:[[SLSharedConfig sharedInstance].timeIntervals[self.checkNumber.integerValue] integerValue] * 60 * 60];
}

@end