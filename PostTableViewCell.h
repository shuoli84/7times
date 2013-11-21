//
//  PostTableViewCell.h
//  7times
//
//  Created by Li Shuo on 13-11-21.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;
@interface PostTableViewCell : UITableViewCell

@property (nonatomic, strong) Post* post;
@property (nonatomic, readonly, assign) float cellHeight;
@end
