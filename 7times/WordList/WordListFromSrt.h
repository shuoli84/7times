//
// Created by Li Shuo on 13-12-3.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface WordListFromSrt : NSObject

@property (nonatomic, strong) NSString *name;

-(id)initWithName:(NSString*)name filename:(NSString*)filename sourceId:(NSString*)sourceId;
-(void)load;
@end