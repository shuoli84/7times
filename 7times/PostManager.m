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

@interface PostManager ()
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *freshPosts;
@property (nonatomic, strong) NSMutableSet *showedPostIds;
@property (nonatomic, strong) NSMutableDictionary *wordShowedPostsNumber;
@property (nonatomic, strong) NSFetchedResultsController *wordsFetchedResultsController;
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
        self.wordsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[PostManager fetchRequest] managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:@"wordsCacheInPostManager"];
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

+(NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Word"];
    fetchRequest.fetchLimit = 50;
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:
        @"checkNumber < 7 AND nextCheckTime <= %@ && postNumber > 0", [NSDate date]];
    fetchRequest.predicate = fetchPredicate;

    NSSortDescriptor *checkNumberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checkNumber" ascending:NO];
    NSSortDescriptor *addTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"added" ascending:YES];
    [fetchRequest setSortDescriptors:@[checkNumberSortDescriptor, addTimeSortDescriptor]];
    return fetchRequest;
}

-(BOOL)needNewPost{
    return self.freshPosts.count < 50;
}

-(void)loadPost{
    [self.wordsFetchedResultsController performFetch:nil];
    for(Word *word in self.wordsFetchedResultsController.fetchedObjects){
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
    if(self.posts.count > indexPath.row){
        [self.posts removeObjectAtIndex:(uint)indexPath.row];
    }
    else{
        [self.freshPosts removeObjectAtIndex:(uint)indexPath.row - self.posts.count];
    }
}
@end