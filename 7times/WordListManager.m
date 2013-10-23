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
NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

NSArray *wordlistArray = @[
    @[@"com.menic.7times.cet4", @"cet4"],
    @[@"com.menic.7times.cet6", @"cet6"],
    @[@"com.menic.7times.tofle", @"tofle"],
    @[@"com.menic.7times.sat", @"sat"],
    @[@"com.menic.7times.gmat", @"gmat"],
    @[@"com.menic.7times.gre", @"gre"],
    @[@"com.menic.7times.ielts1200", @"ielts1200"]
];

        for(NSArray *l in wordlistArray){
            NSString* name = l[0];
            NSString* filename = l[1];
            WordList *tofle = [[WordList alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
            tofle.name = name;

[dictionary setObject:tofle forKey:name];
}

self.allWordLists = dictionary;
}

    return self;
}
@end