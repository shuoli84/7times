//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WordListManager.h"
#import "WordList.h"


@implementation WordListManager {

}

-(id)init{
    self = [super init];

    if(self){
        NSMutableArray *lists = [NSMutableArray array];
        WordList *tofle = [[WordList alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tofle" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
        tofle.name = @"Tofle";

        [lists addObject:tofle];

        WordList *sat = [[WordList alloc] initWithString:[NSString stringWithContentsOfFile:
                [[NSBundle mainBundle] pathForResource:@"sat" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
        sat.name = @"SAT";

        [lists addObject:sat];

        self.allWordLists = lists;
    }

    return self;
}
@end