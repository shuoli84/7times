//
//  Word.h
//  7times
//
//  Created by Li Shuo on 13-9-12.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Check;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSDate * added;
@property (nonatomic, retain) NSSet *post;
@property (nonatomic, retain) NSSet *check;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addPostObject:(NSManagedObject *)value;
- (void)removePostObject:(NSManagedObject *)value;
- (void)addPost:(NSSet *)values;
- (void)removePost:(NSSet *)values;

- (void)addCheckObject:(Check *)value;
- (void)removeCheckObject:(Check *)value;
- (void)addCheck:(NSSet *)values;
- (void)removeCheck:(NSSet *)values;

@end
