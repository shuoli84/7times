//
// Created by Li Shuo on 13-10-15.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface LocalWordList : NSObject

@property (nonatomic, strong) NSString *name;

-(id)initWithString:(NSString*)string;
-(NSArray*)words;
@end