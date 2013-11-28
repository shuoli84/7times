//
//  Check.h
//  7times
//
//  Created by Li Shuo on 13-11-28.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post, Word;

@interface Check : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) Word *word;

@end
