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

@interface PostDownloader ()
@property (nonatomic, strong) GoogleNewsSource *googleNewsSource;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSFetchedResultsController *wordsFetchedResultsController;
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
    }

    return self;
}

- (void)startWithShouldBeginBlock:(BOOL(^)())shouldBeginBlock oneWordFinish:(void (^)(NSString *word))oneWordFinish completion:(void (^)())completion {
    typeof(self) __weak weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
        dispatch_async(_downloadQueue, ^{
            [weakSelf downloadWithOneWordFinish:oneWordFinish completion:completion];
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
    [NSThread sleepForTimeInterval:1];
}

-(void)downloadWithOneWordFinish:(void(^)(NSString* word))oneWordFinish completion:(void(^)())completion{
    NSLog(@"Start download posts for words");
    NSArray *wordArray = self.wordListNeedPosts;

    for(Word *word in wordArray){
        if(word.postNumber.integerValue == 0){
            [self throttleRequest];
            if([self.googleNewsSource download:word]){
                if(oneWordFinish){
                    oneWordFinish(word.word);
                }
            }
            else{
                NSLog(@"Failed to download, break the download loop and try next time");
                break;
            }
        }
    }
    if(completion){
        completion();
    }

    NSLog(@"Posts download finished");
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