//
//  Post.h
//  7times
//
//  Created by Li Shuo on 13-9-12.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check, Word;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) Check *check;
@property (nonatomic, retain) NSSet *word;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addWordObject:(Word *)value;
- (void)removeWordObject:(Word *)value;
- (void)addWord:(NSSet *)values;
- (void)removeWord:(NSSet *)values;

@end
