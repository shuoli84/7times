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

- (Check *)lastCheck {
    Check *c;
    NSDate *lastCheckDate = [NSDate dateWithTimeIntervalSince1970:0];
    for (Check *check in self.check) {
        if ([lastCheckDate compare:check.date] == NSOrderedAscending) {
            lastCheckDate = check.date;
            c = check;
        }
    }

    return c;
}

-(void)checkItNow {
    Check *check = [Check MR_createEntity];
    check.date = [NSDate date];
    [self addCheckHelper:check];
}

- (void)addCheckHelper:(Check *)check {
    [self addCheckObject:check];
    self.lastCheckTime = check.date;
    self.checkNumber = @(self.checkNumber.integerValue + 1);
    self.nextCheckTime = [check.date dateByAddingTimeInterval:[[SLSharedConfig sharedInstance].timeIntervals[(uint) self.checkNumber.integerValue] integerValue] * 60 * 60];
}

@end