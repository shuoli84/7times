//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/NSTimer+BlocksKit.h>


#import "PostManager.h"
#import "Word.h"
#import "Post.h"
#import "Word+Util.h"
#import "Check.h"
#import "Flurry.h"

@interface PostManager ()
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *freshPosts;
@property (nonatomic, strong) NSMutableSet *showedPostIds;
@property (nonatomic, strong) NSMutableDictionary *wordShowedPostsNumber;
@end

@implementation PostManager {
    NSTimer* _timer;
}

-(id)init{
    self = [super init];

    if(self != nil){
        self.posts = [NSMutableArray array];
        self.freshPosts = [NSMutableArray array];
        self.showedPostIds = [NSMutableSet set];
        self.wordShowedPostsNumber = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    typeof(self) __weak weakSelf = self;
    _timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
        [weakSelf loadPost];
    } repeats:YES];
    [_timer fire];

    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(void)end{
    [_timer invalidate];
}

-(void)dealloc{
    [_timer invalidate];
}

-(BOOL)needNewPost{
    return self.freshPosts.count < 50;
}

-(void)loadPost{
    for (Word *word in self.wordListNeedToProcess) {
        if(word.lastCheckExpired){
            [self loadPostForWord:word];
        }
    }
}

-(void)loadPostForWord:(Word *)word{
    if (word.checkNumber.integerValue == 0) {
        if (!self.needNewPost) {
            return;
        }
    }

    if(word.word && [self.wordShowedPostsNumber[word.word] integerValue] < 2){
        NSArray* posts = [word.post sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
        for(Post *p in posts){
            if(!p.checked){
                if(![self.showedPostIds containsObject:p.objectID]){
                    int index = 0;
                    if(word.check.count > 0){
                        [self.posts addObject:p];
                        index = self.posts.count - 1;
                    }
                    else{
                        [self.freshPosts addObject:p];
                        index = self.posts.count + self.freshPosts.count - 1;
                    }
                    [self.showedPostIds addObject:p.objectID];
                    self.wordShowedPostsNumber[word.word] = @([self.wordShowedPostsNumber[word.word] integerValue] + 1);

                    if(self.postChangeBlock){
                        self.postChangeBlock(self, p, -1, index);
                    }

                    if([self.wordShowedPostsNumber[word.word] integerValue]>=2){
                        break;
                    }
                }
            }
        }
    }
}

-(int)postCount{
    return self.posts.count + self.freshPosts.count;
}

-(Post*)postForIndexPath:(NSIndexPath *)indexPath{
    if(self.posts.count > indexPath.row){
        return self.posts[(uint)indexPath.row];
    }
    else{
        return self.freshPosts[(uint)(indexPath.row - self.posts.count)];
    }
}

-(void)removePostAtIndexPath:(NSIndexPath *)indexPath{
    Post *post = [self postForIndexPath:indexPath];
    [self dismissPost:post];
    if(self.posts.count > indexPath.row){
        [self.posts removeObjectAtIndex:(uint)indexPath.row];
    }
    else{
        [self.freshPosts removeObjectAtIndex:(uint)indexPath.row - self.posts.count];
    }
}

- (void)dismissPost:(Post *)post {
    Word *word = post.word;
    [self.showedPostIds removeObject:post.objectID];
    int wordShowedPostNumber = [self.wordShowedPostsNumber[word.word] integerValue];
    self.wordShowedPostsNumber[word.word] = @(wordShowedPostNumber - 1);
}

- (NSArray *)allPosts {
    NSMutableArray *resultArray = [NSMutableArray arrayWithArray:self.posts];
    [resultArray addObjectsFromArray:self.freshPosts];
    return resultArray;
}

- (void)markPostAsRead:(NSIndexPath *)indexPath {
    Post *p = [self postForIndexPath:indexPath];
    Check *check = [Check MR_createEntity];
    check.date = [NSDate date];
    [p setCheck:check];

    p.checked = [NSNumber numberWithBool:YES];

    Word *w = p.word;
    if ([w lastCheckExpired]) {
        [w addCheckHelper:check];
    }
    else {
        NSLog(@"Not ready for a new check, ignore");
    }

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    [self removePostAtIndexPath:indexPath];
    if (self.postChangeBlock) {
        self.postChangeBlock(self, p, indexPath.row, -1);
    }

    [Flurry logEvent:@"Post_dismiss" withParameters:@{
        @"word" : [p.word word],
        @"post" : p.title ? p.title : @"",
        @"post_url" : p.url ? p.url : @"",
    }];
}

- (NSArray *)wordListNeedToProcess {
    NSFetchedResultsController *fetchController = [Word MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"checkNumber < 7 AND nextCheckTime <= %@ && postNumber > 0" argumentArray:@[NSDate.date]] sortedBy:@"checkNumber" ascending:NO];
    fetchController.fetchRequest.fetchLimit = 50;
    if ([fetchController performFetch:nil]) {
        return fetchController.fetchedObjects;
    }
    return nil;
}
@end