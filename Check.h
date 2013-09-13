//
//  Check.h
//  7times
//
//  Created by Li Shuo on 13-9-12.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Check : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSManagedObject *post;
@property (nonatomic, retain) NSManagedObject *word;

@end
