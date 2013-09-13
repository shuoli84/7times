//
// Created by Li Shuo on 13-9-11.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SLWordManager.h"
#import "SLWordItem.h"


@implementation SLWordManager {

}

+(SLWordManager *)defaultManager{
    static SLWordManager *manager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[SLWordManager alloc] init];
    });

    return manager;
}

-(id)init{
    self = [super init];

    if (self){
        self.words = [NSMutableArray array];
    }

    return self;
}
@end