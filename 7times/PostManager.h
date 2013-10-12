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

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableSet *showedPostIds;
@property (nonatomic, strong) NSMutableDictionary *wordWithPosts;

@property (nonatomic, copy) void (^postChangeBlock)(PostManager *postManager, Post* post, int index, int newIndex);

-(void)loadPost;
-(void)loadPostForWord:(Word *)word;

@end