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

-(id)init{
    self = [super init];

    if (self){
        self.googleNewsSource = [[GoogleNewsSource alloc] init];
        _downloadQueue = dispatch_queue_create(NULL, NULL);
        _downloadQueueForSingleWord = dispatch_queue_create(NULL, NULL);

        self.wordsFetchedResultsController = [Word MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"checkNumber < 7 AND postNumber == 0"] sortedBy:@"added" ascending:YES];
        self.wordsFetchedResultsController.fetchRequest.fetchLimit = 50;

        self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        self.reachability.reachableOnWWAN = NO;

        [self.reachability startNotifier];
    }

    return self;
}

- (void)start {
    typeof(self) __weak weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
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
    if(self.reachability.isReachableViaWiFi){
        NSLog(@"Start download posts for words");
        NSArray *wordArray = self.wordListNeedPosts;

        for(Word *word in wordArray){
            if(word.postNumber.integerValue == 0){
                [self throttleRequest];

                // Also protect from each download
                // When the first check is valid, then user disable wifi, it may hit this
                if(self.reachability.isReachableViaWiFi){
                    if([self.googleNewsSource download:word]){
                        NSLog(@"Succeeded");
                    }
                    else{
                        NSLog(@"Failed to download, break the download loop and try next time");
                        break;
                    }
                }
            }
        }

        NSLog(@"Posts download finished");
    }
}

-(void)downloadForWord:(NSString*)word completion:(void(^)())completion{
    dispatch_async(_downloadQueueForSingleWord, ^{
        Word *word1 = [Word MR_findFirstByAttribute:@"word" withValue:word];
        NSLog(@"Start download posts for word: %@", word);
        [self.googleNewsSource download:word1];
        NSLog(@"Finish download for word: %@", word);
        
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