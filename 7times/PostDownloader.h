//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Word;


@interface PostDownloader : NSObject

- (void)startWithShouldBeginBlock:(BOOL(^)())shouldBeginBlock oneWordFinish:(void (^)(NSString *word))oneWordFinish completion:(void (^)())completion;

-(void)end;
-(void)fire;

-(void)downloadWithOneWordFinish:(void(^)(NSString* word))oneWordFinish completion:(void(^)())completion;
-(void)downloadForWord:(NSString*)word completion:(void(^)())completion;

-(NSArray*)wordListNeedPosts;

+ (NSFetchRequest *)fetchRequest;
@end