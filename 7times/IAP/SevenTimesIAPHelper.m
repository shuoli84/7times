//
// Created by Li Shuo on 13-10-18.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "SevenTimesIAPHelper.h"


@implementation SevenTimesIAPHelper {

}

+ (SevenTimesIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static SevenTimesIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
            @"com.menic.7times.cet4",
            @"com.menic.7times.cet6",
            @"com.menic.7times.tofle",
            @"com.menic.7times.sat",
            @"com.menic.7times.gmat",
            @"com.menic.7times.gre",
            @"com.menic.7times.ielts1200",
            @"com.menic.7times.the_big_bang_01",
            nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end