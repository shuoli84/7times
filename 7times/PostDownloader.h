//
// Created by Li Shuo on 13-10-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface PostDownloader : NSObject

-(void)start;
-(void)end;

-(void)download;

-(NSArray*)wordListNeedPosts;
@end