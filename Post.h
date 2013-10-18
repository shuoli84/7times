//
//  Post.h
//  7times
//
//  Created by Li Shuo on 13-10-18.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check, Word;

@interface Post : NSManagedObject

@property(nonatomic, retain) NSNumber *checked;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *source;
@property(nonatomic, retain) NSString *summary;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) Check *check;
@property(nonatomic, retain) Word *word;

@end
