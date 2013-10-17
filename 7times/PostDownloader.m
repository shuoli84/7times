//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PostDownloader.h"
#import "GoogleNewsSource.h"
#import "NSTimer+BlocksKit.h"
#import "Word+Util.h"
#import "Word.h"

@interface PostDownloader ()
@property (nonatomic, strong) GoogleNewsSource *googleNewsSource;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation PostDownloader {
    dispatch_queue_t _downloadQueue;
}

-(id)init{
    self = [super init];

    if (self){
        self.googleNewsSource = [[GoogleNewsSource alloc] init];
        _downloadQueue = dispatch_queue_create(NULL, NULL);
    }

    return self;
}

-(void)start{
    typeof(self) __weak weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
        dispatch_async(_downloadQueue, ^{
            if(weakSelf.readyForLoad){
                [weakSelf download];
            }
        });
    } repeats:YES];
    [self.timer fire];

    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(void)end{
    [self.timer invalidate];
}

-(BOOL)readyForLoad{
    return YES;
}

-(NSArray*)wordListNeedPosts {
    NSArray* wordArray = [Word MR_findAll];
    wordArray = [wordArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Word * evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.post.count == 0;
    }]];
    return wordArray;
}

-(void)throttleRequest{
    // Naive implement, just sleep 1 second for each request
    [NSThread sleepForTimeInterval:1];
}

-(void)download{
    NSLog(@"Start download posts for words");
    NSArray *wordArray = self.wordListNeedPosts;

    for(Word *word in wordArray){
        if(word.lastCheckExpired){
            [self throttleRequest];
            [self.googleNewsSource download:word];
        }
    }

    NSLog(@"Posts download finished");
}

-(void)downloadForWord:(NSString*)word{
    dispatch_async(_downloadQueue, ^{
        Word *word1 = [Word MR_findFirstByAttribute:@"word" withValue:word];
        if(word1.lastCheckExpired){
            NSLog(@"Start download posts for word: %@", word);
            [self.googleNewsSource download:word1];
            NSLog(@"Finish download for word: %@", word);
        }
    });
}

-(void)dealloc{
    [self.timer invalidate];
}
@end