//
// Created by Li Shuo on 13-11-25.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WeiboUserInfo.h"


@implementation WeiboUserInfo {

}

-(id)initWithRequestUserInfo:(NSDictionary *)userInfo {
    if((self = super.init)){
        self.uid = userInfo[@"idstr"];
        self.name = userInfo[@"name"];
        self.profileImageUrl = userInfo[@"profile_image_url"];
    }
    return self;
}
@end