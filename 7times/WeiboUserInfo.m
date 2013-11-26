//
// Created by Li Shuo on 13-11-25.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "WeiboUserInfo.h"


@implementation WeiboUserInfo {

}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.profileImageUrl forKey:@"profileImageUrl"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super init])){
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.profileImageUrl = [aDecoder decodeObjectForKey:@"profileImageUrl"];
    }
    return self;
}

-(id)initWithRequestUserInfo:(NSDictionary *)userInfo {
    if((self = super.init)){
        self.uid = userInfo[@"idstr"];
        self.name = userInfo[@"name"];
        self.profileImageUrl = userInfo[@"profile_image_url"];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if((self = super.init)){
        if(dictionary){
            self.uid = dictionary[@"uid"];
            self.name = dictionary[@"name"];
            self.profileImageUrl = dictionary[@"profileImageUrl"];
        }
    }
    return self;
}

-(NSDictionary*)dictionaryFromInstance{
    if(self.uid == nil || self.name == nil || self.profileImageUrl == nil){
        return nil;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"uid"] = self.uid;
    dictionary[@"name"] = self.name;
    dictionary[@"profileImageUrl"] = self.profileImageUrl;
    
    return dictionary;
}
@end