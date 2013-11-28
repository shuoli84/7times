//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "SLSharedConfig.h"
#import "PostDownloader.h"
#import "PostManager.h"
#import "LocalWordList.h"
#import "MagicalRecord/MagicalRecord.h"
#import "Wordlist.h"

@implementation SLSharedConfig {
}
+(SLSharedConfig *)sharedInstance{
    static SLSharedConfig *sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[SLSharedConfig alloc]init];
    });

    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self){
        _colors =@[
            [UIColor colorWithRed:231.f/255.f green:76/255.f blue:60/255.f alpha:1.f],
            [UIColor colorWithRed:255.f/255.f green:128/255.f blue:0/255.f alpha:1.f],
            [UIColor colorWithRed:241.f/255.f green:196/255.f blue:15/255.f alpha:1.f],
            [UIColor colorWithRed:39.f/255.f green:174/255.f blue:96/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:73/255.f blue:94/255.f alpha:1.f],
            [UIColor colorWithRed:52.f/255.f green:152/255.f blue:219/255.f alpha:1.f],
            [UIColor colorWithRed:155.f/255.f green:89/255.f blue:182/255.f alpha:1.f],
        ];

        _timeIntervals = @[@0, @8, @18, @40, @(3 * 24 - 8), @(5 * 24 - 8), @(7 * 24 - 8), @(10 * 24 - 8), @(1024 * 24)];
        self.postDownloader = [[PostDownloader alloc] init];
        [self.postDownloader startWithShouldBeginBlock:nil oneWordFinish:nil completion:nil];
        self.postManager = [[PostManager alloc] init];

        self.timeFormmater = [[TTTTimeIntervalFormatter alloc] init];

        Wordlist *wordList = [Wordlist MR_findFirstByAttribute:@"name" withValue:@"todo"];
        if(wordList == nil){
            wordList = [Wordlist MR_createEntity];
            wordList.name = @"todo";

            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        }

        self.todoList = wordList;
    }

    return self;
}

-(UIColor*)colorForCount:(int)count{
    if(count >= _colors.count){
        count = _colors.count - 1;
    }

    if(count < 0){
        count = 0;
    }

    return _colors[(unsigned int)count];
}
@end