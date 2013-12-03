//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WordListManager.h"
#import "LocalWordList.h"
#import "WordListFromSrt.h"


@implementation WordListManager {

}

-(id)init{
    self = [super init];

    if(self){
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

        NSArray *wordlistArray = @[
            @[@"com.menic.7times.cet4", @"cet4", @"CET4"],
            @[@"com.menic.7times.cet6", @"cet6", @"CET6"],
            @[@"com.menic.7times.tofle", @"tofle", @"TOFLE"],
            @[@"com.menic.7times.sat", @"sat", @"SAT"],
            @[@"com.menic.7times.gmat", @"gmat", @"GMAT"],
            @[@"com.menic.7times.gre", @"gre", @"GRE"],
            @[@"com.menic.7times.ielts1200", @"ielts1200", @"IELTS"],
            @[@"com.menic.7times.the_big_bang_01", @"the-big-bang-01.words.json", @"The Big Bang 01"]
        ];

        for(NSArray *l in wordlistArray){
            NSString *productId = l[0];
            NSString *filename = l[1];

            if([filename rangeOfString:@".json"].location == NSNotFound){
                LocalWordList *wordlist = [[LocalWordList alloc] initWithString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
                wordlist.name = l[2];

                [dictionary setObject:wordlist forKey:productId];
            }
            else{
                WordListFromSrt *wordListFromSrt= [[WordListFromSrt alloc] initWithName:l[2] filename:filename sourceId:productId];

                [dictionary setObject:wordListFromSrt forKey:productId];
            }


        }

        self.allWordLists = dictionary;
}

    return self;
}
@end