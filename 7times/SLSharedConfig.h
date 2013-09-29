//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SLSharedConfig : NSObject

@property (nonatomic, assign) int wordLimitPerHour;
@property (nonatomic, strong) NSString* googleNewsFeedURL;
@property (nonatomic, strong) NSArray* colors;

-(UIColor*)colorForCount:(int)count;

+(SLSharedConfig *)sharedInstance;

@property (nonatomic, copy) void(^coreDataReady)();
@end