//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WordList.h"
#import "NSArray+BlocksKit.h"


@interface WordList ()

@property (nonatomic, strong) NSArray* wordList;

@end

@implementation WordList {

}

-(id)initWithString:(NSString *)string {
    self = [super init];

    if(self){
        NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        words = [words map:^id(NSString* word) {
            return [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }];

        words = [words filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString* evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject.length > 0;
        }]];

        self.wordList = words;
    }

    return self;
}

-(NSArray*)words{
    return self.wordList;
}
@end