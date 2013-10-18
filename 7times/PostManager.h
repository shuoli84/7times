//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class MWFeedParser;
@class Post;
@class Word;


@interface PostManager : NSObject

@property (nonatomic, copy) void (^postChangeBlock)(PostManager *postManager, Post* post, int index, int newIndex);

- (void)startWithShouldBeginBlock:(BOOL (^)())shouldBeginBlock;

-(void)end;

-(void)loadPost;
-(void)loadPostForWord:(Word *)word;

-(int)postCount;
-(Post*)postForIndexPath:(NSIndexPath *)indexPath;
-(void)removePostAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)needNewPost;

+(NSFetchRequest *)fetchRequest;

@end