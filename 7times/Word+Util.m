//
// Created by Li Shuo on 13-10-9.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Word+Util.h"
#import "Check.h"
#import "SLSharedConfig.h"
#import "Post.h"


@implementation Word (Util)

-(BOOL)lastCheckExpired {
    if(self.check.count >= 7){
        return NO;
    }

    Check *lastCheck = self.lastCheck;
    NSDate *lastCheckDate = [NSDate dateWithTimeIntervalSince1970:0];
    if(lastCheck != nil){
        lastCheckDate = lastCheck.date;
    }

    int shouldWaitHours = [[SLSharedConfig sharedInstance].timeIntervals[self.check.count] integerValue];
    if([[NSDate date] timeIntervalSinceDate:lastCheckDate] >= shouldWaitHours * 60 * 60){
        return YES;
    }
    return NO;
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
        if(word2.check.count == 0){
            return NSOrderedAscending;
        }

        if(word1.check.count == 0){
            return NSOrderedDescending;
        }

        Check *lastCheck1 = word1.lastCheck;
        Check *lastCheck2 = word2.lastCheck;

        NSArray *timeIntervals = [SLSharedConfig sharedInstance].timeIntervals;
        int interval1 = [timeIntervals[word1.check.count] integerValue];
        int interval2 = [timeIntervals[word2.check.count] integerValue];

        NSDate *time1 = [lastCheck1.date dateByAddingTimeInterval:interval1 * 60 * 60];
        NSDate *time2 = [lastCheck2.date dateByAddingTimeInterval:interval2 * 60 * 60];

        return [time1 compare:time2];
    };
}

-(NSArray*)unCheckedPosts{
    NSMutableArray *result = [NSMutableArray array];

    for(Post *post in self.post){
        if(post.check == nil){
            [result addObject:post];
        }
    }

    return result;
}

@end