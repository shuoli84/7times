//
// Created by Li Shuo on 13-11-29.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface GoogleNewsScrubber : NSObject

-(NSString*)scrubTitle:(NSString*)title;
-(NSString*)scrubContent:(NSString*)content;

@end