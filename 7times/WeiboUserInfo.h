//
// Created by Li Shuo on 13-11-25.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface WeiboUserInfo : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *profileImageUrl;

-(id)initWithRequestUserInfo:(NSDictionary *)userInfo;
@end