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

-(NSString*)googleNewsFeedURL {
    return @"https://news.google.com/news?pz=1&num=14&cf=all&ned=us&output=rss&q=%@";
}

-(id)init{
    self = [super init];
    if (self){
        self.wordLimitPerHour = 20;
        self.googleNewsFeedURL = @"https://news.google.com/news?q=%@&output=rss";
        _colors =@[
            [UIColor colorWithRed:231.f/255.f green:76/255.f blue:60/255.f alpha:1.f],
            [UIColor colorWithRed:255.f/255.f green:128/255.f blue:0/255.f alpha:1.f],
            [UIColor colorWithRed:241.f/255.f green:196/255.f blue:15/255.f alpha:1.f],
            [UIColor colorWithRed:39.f/255.f green:174/255.f blue:96/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:73/255.f blue:94/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:152/255.f blue:219/255.f alpha:1.f],
            [UIColor colorWithRed:155.f/255.f green:89/255.f blue:182/255.f alpha:1.f],
            ];
    }

    return self;
}

-(UIColor*)colorForCount:(int)count{
    if(count >= _colors.count){
        count = _colors.count - 1;
    }

    if(count < 0){
        count = 0;
    }

    return _colors[count];
}
@end