//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <BlocksKit/A2DynamicDelegate.h>
#import "GoogleNewsSource.h"
#import "RXMLElement.h"
#import "Word.h"
#import "MWFeedParser.h"
#import "Post.h"


@implementation GoogleNewsSource {

}

BOOL pureTextFont(RXMLElement* element){
    if([element children:@"font"].count > 0){
        return NO;
    }
    if([element.tag isEqualToString:@"font"]){
        BOOL __block notPureText = NO;
        [element iterate:@"*" usingBlock:^(RXMLElement *elm) {
            if(!pureTextFont(elm)){ notPureText = YES; }
        }];

        if(notPureText){return NO;}
    }

    return YES;
}

-(NSString*)buildURL:(NSString*)searchWord{
    NSString *str = [NSString stringWithFormat:@"https://news.google.com/news?pz=1&num=14&cf=all&ned=us&output=rss&q=%@", searchWord];
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

            Post *post = [Post MR_findFirstByAttribute:@"id" withValue:item.identifier];
            if(post == nil){
                post = [Post MR_createEntity];
                post.id = item.identifier;
                post.title = title;
                post.source = source;
                post.summary = summary;
                post.date = item.date;
                post.url = item.link;
            }

            post.word = word;
            word.postNumber = @(word.postNumber.integerValue + 1);
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        }
    }

    return returnValue;
}

@end