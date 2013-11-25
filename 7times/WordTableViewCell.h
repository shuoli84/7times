//
// Created by Li Shuo on 13-11-23.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Word;


@interface WordTableViewCell : UITableViewCell

@property (nonatomic, strong) Word* word;
@property (nonatomic, copy) void (^showDefinitionBlock)(NSString* word);

@end