//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WordListManager.h"
#import "LocalWordList.h"
#import "WordListFromSrt.h"


@interface WordListManager()
@property (nonatomic, strong) NSArray* productsArray;
@end

@implementation WordListManager {

}

-(id)init{
    self = [super init];

    if(self){
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

        NSArray *wordlistArray = @[
            @[@"com.menic.7times.cet4", @"cet4", @"CET4", @0],
            @[@"com.menic.7times.ogden2000", @"ogden2000", @"Ogden 2000 cover 90% english usage", @1],
            @[@"com.menic.7times.cet6", @"cet6", @"CET6", @2],
            @[@"com.menic.7times.tofle", @"tofle", @"TOFLE", @3],
            @[@"com.menic.7times.sat", @"sat", @"SAT", @4],
            @[@"com.menic.7times.gmat", @"gmat", @"GMAT", @5],
            @[@"com.menic.7times.ielts1200", @"ielts1200", @"IELTS", @6],
            @[@"com.menic.7times.gre", @"gre", @"GRE", @7],
            @[@"com.menic.7times.the_big_bang_01", @"the-big-bang-01.words.json", @"The Big Bang 01", @8],
            @[@"com.menic.7times.the_big_bang_02_03", @"the-big-bang-02-03.words.json", @"The Big Bang 02-03", @9],
            @[@"com.menic.7times.the_big_bang_04_05", @"the-big-bang-04-05.words.json", @"The Big Bang 04-05", @10],
        ];

        self.productsArray = wordlistArray;

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

-(NSInteger)sortOrderForProduct:(NSString *)productIdentifier {
    for(NSArray *product in self.productsArray){
        if([product[0] isEqualToString:productIdentifier]){
            return [product[3] integerValue];
        }
    }
    return 0;
}
@end