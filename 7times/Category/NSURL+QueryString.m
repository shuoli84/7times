//
// Created by Li Shuo on 13-10-9.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSURL+QueryString.h"


@implementation NSURL (QueryString)

-(NSDictionary *)dictionaryForQueryString{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
    NSString* query = self.query;
    NSArray *components = [query componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
    for(NSString *kv in components){
        NSArray *kvArray = [kv componentsSeparatedByString:@"="];
        if(kvArray.count == 2){
            NSString *key = kvArray[0];
            NSString *value = kvArray[1];
            key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [resultDictionary setObject:value forKey:key];
        }
    }

    return resultDictionary;
}
@end