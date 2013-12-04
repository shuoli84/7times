//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Word;
@class Wordlist;

@interface PostDownloader : NSObject

- (instancetype)initWithWordList:(Wordlist*)wordlist;
- (void)start;
- (void)end;

- (void)fire;

- (void)downloadForWord:(Word *)word completion:(void (^)())completion;

- (NSArray *)wordListNeedPosts;
@end