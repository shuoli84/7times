//
// Created by Li Shuo on 13-11-22.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Post;


@interface PostDetailViewController : UIViewController

@property (nonatomic, strong) Post *post;

@property (nonatomic, weak) UIReferenceLibraryViewController *wordReferenceViewController;
@end