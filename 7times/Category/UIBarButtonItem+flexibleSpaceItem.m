//
//  UIBarButtonItem+flexibleSpaceItem.m
//  7times
//
//  Created by Li Shuo on 13-11-24.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "UIBarButtonItem+flexibleSpaceItem.h"

@implementation UIBarButtonItem (flexibleSpaceItem)

+(UIBarButtonItem*)flexibleSpaceItem{
    return [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}
@end
