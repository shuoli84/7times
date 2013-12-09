//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "PostDownloader.h"
#import "GoogleNewsSource.h"
#import "NSTimer+BlocksKit.h"
#import "Word+Util.h"
#import "Reachability.h"
#import "SLSharedConfig.h"
#import "Wordlist.h"

@interface PostDownloader ()
@property (nonatomic, strong) GoogleNewsSource *googleNewsSource;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSFetchedResultsController *wordsFetchedResultsController;
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation PostDownloader {
    dispatch_queue_t _downloadQueue;
    dispatch_queue_t _downloadQueueForSingleWord;
}

- (instancetype)initWithWordList:(Wordlist*)wordlist{
    if (self = [super init]){
        self.wordsFetchedResultsController = [Word MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"lists.name CONTAINS %@", wordlist.name] sortedBy:@"added" ascending:YES];

        self.googleNewsSource = [[GoogleNewsSource alloc] init];
        _downloadQueue = dispatch_queue_create(NULL, NULL);
        _downloadQueueForSingleWord = dispatch_queue_create(NULL, NULL);

        self.reachability = [Reachability reachabilityWithHostname:@"news.google.com"];
        self.reachability.reachableOnWWAN = NO;

        [self.reachability startNotifier];
    }

    return self;
}

- (void)start {
    typeof(self) __weak weakSelf = self;

    self.timer = [NSTimer bk_timerWithTimeInterval:60 block:^(NSTimer* time) {
        dispatch_async(_downloadQueue, ^{
            [weakSelf downloadForWordList];
        });
    } repeats:YES];
    [self.timer fire];

    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(void)end{
    [self.timer invalidate];
}

-(void)fire{
    [self.timer fire];
}

-(NSArray*)wordListNeedPosts {
    if ([self.wordsFetchedResultsController performFetch:nil]) {
        return self.wordsFetchedResultsController.fetchedObjects;
    }
    return nil;
}

-(void)throttleRequest{
    // Naive implement, just sleep 1 second for each request
    [NSThread sleepForTimeInterval:2];
}

-(void)downloadForWordList{
    Wordlist *localNeedsPostList = [[SLSharedConfig sharedInstance].needsPostList MR_inThreadContext];
    if(self.reachability.isReachableViaWiFi){
        NSLog(@"Start download posts for words");
        NSArray *wordArray = self.wordListNeedPosts;

        for(Word *word in wordArray){
            [self throttleRequest];

            // Also protect from each download
            // When the first check is valid, then user disable wifi, it may hit this
            if(self.reachability.isReachableViaWiFi){
                if([self.googleNewsSource download:word]){
                    NSLog(@"Succeeded");
                    [word removeListsObject:localNeedsPostList];

                    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:nil];
                }
                else{
                    NSLog(@"Failed to download, break the download loop and try next time");
                    break;
                }
            }
        }

        NSLog(@"Posts download finished");
    }
}

-(void)downloadForWord:(Word*)word completion:(void(^)())completion{
    dispatch_async(_downloadQueueForSingleWord, ^{
        Word *localWord = [word MR_inThreadContext];
        NSLog(@"Start download posts for word: %@", localWord.word);
        [self.googleNewsSource download:localWord];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:nil];
        NSLog(@"Finish download for word: %@", localWord.word);
        
        if(completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

-(void)dealloc{
    [self.timer invalidate];
}
@end