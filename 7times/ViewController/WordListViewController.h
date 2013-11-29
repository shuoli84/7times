//
// Created by Li Shuo on 13-10-12.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface WordListViewController : UIViewController

@property (nonatomic, copy) void(^finishLoadWordlist)();

- (IBAction)recover:(id)sender;
@end