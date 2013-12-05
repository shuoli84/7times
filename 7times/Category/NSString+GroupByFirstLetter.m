//
// Created by Li Shuo on 13-12-5.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "NSString+GroupByFirstLetter.h"


@implementation NSString (GroupByFirstLetter)

-(NSString*)firstLetter{
    if (!self.length || self.length == 1)
        return self;
    return [self substringToIndex:1].lowercaseString;
}
@end