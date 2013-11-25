//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PostDownloader;
@class PostManager;
@class TTTTimeIntervalFormatter;
@class WeiboUserInfo;

@interface SLSharedConfig : NSObject

@property (nonatomic, strong) NSArray* colors;
@property (nonatomic, strong) NSArray* timeIntervals;
@property (nonatomic, strong) PostDownloader *postDownloader;
@property(nonatomic, strong) PostManager *postManager;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeFormmater;
@property (nonatomic, strong) NSDictionary *weiboUserLoginInfo;
@property (nonatomic, strong) WeiboUserInfo *weiboUser;

-(UIColor*)colorForCount:(int)count;

+(SLSharedConfig *)sharedInstance;
@end