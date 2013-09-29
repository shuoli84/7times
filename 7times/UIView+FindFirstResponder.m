//
// Created by Li Shuo on 13-9-17.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIView+FindFirstResponder.h"


@implementation UIView (FindFirstResponder)

-(UIView*)firstResponder{
    if([self isFirstResponder]){
        return self;
    }

    for(UIView *childView in self.subviews){
        UIView *v = [childView firstResponder];
        if(v){
            return v;
        }
    }

    return nil;
}

@end