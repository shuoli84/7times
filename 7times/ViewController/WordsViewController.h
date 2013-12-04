//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RunningModel){
    RunningModelAll,
    RunningModelTodo,
};

@class Wordlist;
@interface WordsViewController : UIViewController

@property (nonatomic, strong) Wordlist *wordList;
@property (nonatomic, assign) BOOL enableTodoMode;
@end