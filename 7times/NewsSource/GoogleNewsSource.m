//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/A2DynamicDelegate.h>
#import "GoogleNewsSource.h"
#import "Word.h"
#import "MWFeedParser.h"
#import "Post.h"
#import "Wordlist.h"


@implementation GoogleNewsSource {

}

-(NSString*)buildURL:(NSString*)searchWord{
    NSString *str = [NSString stringWithFormat:@"https://news.google.com/news?pz=1&num=30&cf=all&ned=us&output=rss&q=\"%@\"", searchWord];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

-(BOOL)download:(Word*)word{
    NSLog(@"Start download from google news for word: %@", word.word);

    BOOL __block returnValue = YES;

    NSURL *feedURL = [NSURL URLWithString:[self buildURL:word.word]];
    MWFeedParser *_feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];

    _feedParser.feedParseType = ParseTypeFull;
    _feedParser.connectionType = ConnectionTypeSynchronously;

    A2DynamicDelegate *delegate = [_feedParser dynamicDelegateForProtocol:@protocol(MWFeedParserDelegate)];

    /*
    Due to NSXmlParser is not reentree, we can't do xml parse inside the delegate. So store the item into the
    array and do the parse after rss parse finished.
     */
    NSMutableArray *rssItems = [NSMutableArray array];

    [delegate implementMethod:@selector(feedParser:didParseFeedItem:) withBlock:^(MWFeedParser *fp, MWFeedItem* item){
        [rssItems addObject:item];
    }];

    [delegate implementMethod:@selector(feedParser:didFailWithError:) withBlock:^(MWFeedParser *fp, NSError* error){
        NSLog(@"Did fail with error: %@", error.localizedDescription);
        returnValue = NO;
    }];
    _feedParser.delegate = (id)delegate;

    [_feedParser parse];

    if(returnValue){
        for(MWFeedItem* item in rssItems){
            NSString *title = item.title;

            Word *localWord = [word MR_inThreadContext];
            BOOL alreadyInList = NO;
            for(Post *post in localWord.post){
                if ([post.id isEqualToString:item.identifier]){
                    alreadyInList = YES;
                    break;
                }
            }

            if(!alreadyInList){
                Post *newPost = [Post MR_createEntity];
                newPost.id = item.identifier;
                newPost.title = title;
                newPost.source = @"Google News";
                newPost.summary = item.summary;
                newPost.date = item.date;
                newPost.url = item.link;

                newPost.word = localWord;
                localWord.postNumber = @(localWord.postNumber.integerValue + 1);
            }
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:nil];
    }

    return returnValue;
}



@end