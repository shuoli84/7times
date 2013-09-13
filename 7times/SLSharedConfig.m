//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SLSharedConfig.h"


@implementation SLSharedConfig {

}
+(SLSharedConfig *)sharedInstance{
    static SLSharedConfig *sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[SLSharedConfig alloc]init];
    });

    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self){
        self.wordLimitPerHour = 20;
        self.googleNewsFeedURL = @"https://news.google.com/news?q=%@&output=rss";
    }

    return self;
}
@end