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

-(BOOL)readyForNewCheck{
    //Only set the check only last check is at least 30 minutes ago
    NSDate* lastCheck = [NSDate dateWithTimeIntervalSince1970:0];
    for(Check *c in self.check){
        if([lastCheck compare:c.date] == NSOrderedAscending){
            lastCheck = c.date;
        }
    }

    int shouldWaitHours = [[SLSharedConfig sharedInstance].timeIntervals[self.check.count] integerValue];
    if([[NSDate date] timeIntervalSinceDate:lastCheck] >= shouldWaitHours * 60){
        return YES;
    }
    return NO;
}

@end