//
//  Wordlist.h
//  7times
//
//  Created by Li Shuo on 13-11-28.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Wordlist : NSManagedObject

@property (nonatomic, retain) NSString * desp;
@property (nonatomic, retain) NSNumber * finished;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * sourceId;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSSet *words;
@end

@interface Wordlist (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
