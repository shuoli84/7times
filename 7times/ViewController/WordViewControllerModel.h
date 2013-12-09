//
//  WordViewControllerModel.h
//  7times
//
//  Created by Li Shuo on 13-12-9.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RunningModel){
    RunningModelAll,
    RunningModelTodo,
};

@interface WordViewControllerModel : NSObject

@property (nonatomic, assign) RunningModel mode;
@end
