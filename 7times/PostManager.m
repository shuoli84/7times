//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/NSTimer+BlocksKit.h>
#import "PostManager.h"
#import "Check.h"
#import "Word.h"
#import "Post.h"
#import "Word+Util.h"

@implementation PostManager {
    NSTimer* _timer;
}

-(id)init{
    self = [super init];

    if(self != nil){
        self.posts = [NSMutableArray array];
        self.showedPostIds = [NSMutableSet set];
        self.wordWithPosts = [NSMutableDictionary dictionary];

        _timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadPost];
            });
        } repeats:YES];
        [_timer fire];

        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

-(void)dealloc{
    [_timer invalidate];
}

-(void)loadPost{
    NSArray* wordArray = [Word MR_findAll];

    wordArray = [wordArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Word * evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.check.count < 7;
    }]];

    wordArray = [wordArray sortedArrayUsingComparator:[Word comparator]];

    for(Word *word in wordArray){
        if(word.lastCheckExpired){
           [self loadPostForWord:word];
        }
    }
}

-(void)loadPostForWord:(Word *)word{
    if(word.word && [self.wordWithPosts[word.word] integerValue] < 2){
        NSArray* posts = [word.post sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
        for(Post *p in posts){
            if(p.check == nil){
                if(![self.showedPostIds containsObject:p.id]){
                    [self.posts addObject:p];
                    [self.showedPostIds addObject:p.id];
                    self.wordWithPosts[word.word] = @([self.wordWithPosts[word.word] integerValue] + 1);

                    if(self.postChangeBlock){
                        self.postChangeBlock(self, p, -1, self.posts.count - 1);
                    }

                    if([self.wordWithPosts[word.word] integerValue]>=2){
                        break;
                    }
                }
            }
        }
    }
}
@end