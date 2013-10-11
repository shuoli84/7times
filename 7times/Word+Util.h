//
// Created by Li Shuo on 13-10-9.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Word.h"

@class Check;

@interface Word (Util)

-(BOOL)readyForNewCheck;
-(BOOL)needsNewPosts;
-(Check *)lastCheck;

+(NSComparator)comparator;

@end