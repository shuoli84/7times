//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class PostDownloader;
@class TTTTimeIntervalFormatter;
@class Wordlist;
@class GoogleNewsScrubber;

@interface SLSharedConfig : NSObject

@property (nonatomic, strong) NSArray* colors;
@property (nonatomic, strong) NSArray* timeIntervals;
@property (nonatomic, strong) PostDownloader *postDownloader;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeFormmater;
@property (nonatomic, strong) Wordlist *manualList;
@property (nonatomic, strong) Wordlist *needsPostList;
@property (nonatomic, strong) Wordlist *noPostDownloadedList;

@property (nonatomic, strong) GoogleNewsScrubber *googleNewsScrubber;

-(UIColor*)colorForCount:(int)count;

+(SLSharedConfig *)sharedInstance;

@end