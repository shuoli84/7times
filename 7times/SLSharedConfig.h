//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PostDownloader;
@class PostManager;

@interface SLSharedConfig : NSObject

@property (nonatomic, strong) NSArray* colors;
@property (nonatomic, strong) NSArray* timeIntervals;
@property (nonatomic, strong) PostDownloader *postDownloader;
@property(nonatomic, strong) PostManager *postManager;

-(UIColor*)colorForCount:(int)count;

+(SLSharedConfig *)sharedInstance;

@property (nonatomic, copy) void(^coreDataReady)();
@end