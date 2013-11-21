//
//  Word.h
//  7times
//
//  Created by Li Shuo on 13-11-15.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check, Post;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSDate * added;
@property (nonatomic, retain) NSNumber * checkNumber;
@property (nonatomic, retain) NSDate * lastCheckTime;
@property (nonatomic, retain) NSDate * nextCheckTime;
@property (nonatomic, retain) NSNumber * postNumber;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSSet *check;
@property (nonatomic, retain) NSOrderedSet *post;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addCheckObject:(Check *)value;
- (void)removeCheckObject:(Check *)value;
- (void)addCheck:(NSSet *)values;
- (void)removeCheck:(NSSet *)values;

- (void)insertObject:(Post *)value inPostAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPostAtIndex:(NSUInteger)idx;
- (void)insertPost:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePostAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPostAtIndex:(NSUInteger)idx withObject:(Post *)value;
- (void)replacePostAtIndexes:(NSIndexSet *)indexes withPost:(NSArray *)values;
- (void)addPostObject:(Post *)value;
- (void)removePostObject:(Post *)value;
- (void)addPost:(NSOrderedSet *)values;
- (void)removePost:(NSOrderedSet *)values;
@end
