//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>

@class LocalWordList;


@interface WordListManager : NSObject

@property (nonatomic, strong) NSDictionary* allWordLists;

-(NSInteger)sortOrderForProduct:(NSString*)productIdentifier;
@end