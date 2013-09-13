//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SLCheck : NSObject

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* checkURL;
@property (nonatomic, strong) NSString* checkSummary;

@end


@interface SLWordItem : NSObject

@property (nonatomic, strong) NSString* word;

/**
* Check array holds all the checks, the count is the total check time.
*/
@property (nonatomic, strong) NSArray* checkArray;

@property (nonatomic, strong) NSDate* added;

/**
* The tags holds arbitrary tag information for a word, like noun, cs, etc. which makes word discovery based on word much easier
*/
@property (nonatomic, strong) NSArray* tags;

@end