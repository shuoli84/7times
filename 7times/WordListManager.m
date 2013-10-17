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

        NSArray *wordlistArray = @[
            @[@"CET4", @"cet4"],
            @[@"CET6", @"cet6"],
            @[@"Tofle", @"tofle"],
            @[@"SAT", @"sat"],
            @[@"GMAT", @"gmat"],
            @[@"GRE", @"gre"],
        ];

        for(NSArray *l in wordlistArray){
            NSString* name = l[0];
            NSString* filename = l[1];
            WordList *tofle = [[WordList alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
            tofle.name = name;

            [lists addObject:tofle];
        }

        self.allWordLists = lists;
    }

    return self;
}
@end