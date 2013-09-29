//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <MWFeedParser/MWFeedParser.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <RaptureXML/RXMLElement.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import "SLPostManager.h"
#import "Check.h"
#import "Word.h"
#import "Post.h"
#import "SLSharedConfig.h"

@implementation SLPostManager {
    MWFeedParser *_feedParser;
    NSTimer* _timer;
}

-(id)init{
    self = [super init];

    if(self != nil){
        self.posts = [NSMutableArray array];
        self.showedPostIds = [NSMutableSet set];
        self.wordWithPosts = [NSMutableDictionary dictionary];
    }

    _timer = [NSTimer timerWithTimeInterval:60 block:^(NSTimer* time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadPost];
        });
    } repeats:YES];
    [_timer fire];

    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];

    return self;
}

-(void)dealloc{
    [_timer invalidate];
}

-(void)loadPost{
    NSArray* array = [Word MR_findAll];
    NSArray* timeIntervalsInHour = @[@0, @12, @24, @48, @(3*24), @(5*24), @(7*24), @(10*24)];
    for(Word *word in array){
        if(word.check.count < 7){
            NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:0];
            for(Check *check in word.check){
                if ([lastTime compare:check.date] == NSOrderedAscending){
                    lastTime = check.date;
                }
            }

            int timeIntervalInHour = [timeIntervalsInHour[word.check.count] integerValue];

            if([[NSDate date] timeIntervalSinceDate:lastTime] > timeIntervalInHour * 60 * 60){
                // If longer than 1 hour, load the post
                [self loadPostForWord:word];
            }
        }
    }
}

BOOL pureTextFont(RXMLElement* element){
    if([element children:@"font"].count > 0){
        return NO;
    }
    if([element.tag isEqualToString:@"font"]){
        BOOL __block notPureText = NO;
        [element iterate:@"*" usingBlock:^(RXMLElement *element) {
            if(!pureTextFont(element)){ notPureText = YES; }
        }];

        if(notPureText){return NO;}
    }

    return YES;
}

-(void)loadPostForWord:(Word *)word{
    if(word.post.count == 0){
        NSString *str = [NSString stringWithFormat:[SLSharedConfig sharedInstance].googleNewsFeedURL, word.word];
        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *feedURL = [NSURL URLWithString:str];
        _feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];

        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeAsynchronously;

        A2DynamicDelegate *delegate = [_feedParser dynamicDelegateForProtocol:@protocol(MWFeedParserDelegate)];
        typeof(self) __weak weakSelf = self;
        [delegate implementMethod:@selector(feedParser:didParseFeedItem:) withBlock:^(MWFeedParser *fp, MWFeedItem* item){
            dispatch_async(dispatch_get_main_queue(), ^{
                RXMLElement *doc = [[RXMLElement alloc] initFromXMLData:[item.summary dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *title = item.title;
                NSString *__block source;
                NSString *__block summary;

                NSMutableArray *textArray = [NSMutableArray array];

                [doc iterateWithRootXPath:@"//font" usingBlock:^(RXMLElement *element) {
                    if(pureTextFont(element)){
                        NSString *value = element.text;
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if(value.length > 0){
                            [textArray addObject:value];
                            if(summary.length < value.length){
                                source = summary;
                                summary = value;
                            }
                        }
                    }
                }];

                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];

                Post *post = [Post MR_findFirstByAttribute:@"id" withValue:item.identifier];
                if(post == nil){
                    post = [Post MR_createInContext:localContext];
                    post.id = item.identifier;
                    post.title = title;
                    post.source = source;
                    post.summary = summary;
                    post.date = item.date;
                    post.url = item.link;
                }

                [post addWordObject:word];

                [localContext MR_saveToPersistentStoreAndWait];
            });
        }];

        [delegate implementMethod:@selector(feedParserDidFinish:) withBlock:^(MWFeedParser *fp){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadPostForWord:word];
            });
        }];

        [delegate implementMethod:@selector(feedParser:didFailWithError:) withBlock:^(MWFeedParser *fp, NSError* error){
            NSLog(@"Did fail with error: %@", error.localizedDescription);
        }];
        _feedParser.delegate = (id)delegate;

        [_feedParser parse];
    }
    else{
        if([self.wordWithPosts[word.word] integerValue] < 2){
            NSArray* posts = [word.post sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
            for(Post *p in posts){
                if(p.check == nil){
                    if(![self.showedPostIds containsObject:p.id]){
                        [self.posts addObject:p];
                        [self.showedPostIds addObject:p];
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
}
@end