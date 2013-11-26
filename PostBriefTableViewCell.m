//
//  PostTableViewCell.m
//  7times
//
//  Created by Li Shuo on 13-11-21.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "PostBriefTableViewCell.h"
#import "Post.h"
#import "SLSharedConfig.h"

@implementation PostBriefTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.detailTextLabel.textColor = [UIColor colorWithRed:127 / 255.f green:140 / 255.f blue:141 / 255.f alpha:1.f];
    }
    return self;
}

-(void)setPost:(Post *)post{
    _post = post;
    self.textLabel.text = post.title;
    self.detailTextLabel.text = [SLSharedConfig.sharedInstance.timeFormmater stringForTimeInterval:post.date.timeIntervalSinceNow];

    if(post.checked.boolValue){
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }

    CGSize size = CGSizeMake(274, CGFLOAT_MAX);
    CGSize titleSize = [self.textLabel sizeThatFits:size];
    CGSize detailSize = [self.detailTextLabel sizeThatFits:size];
    _cellHeight = titleSize.height + detailSize.height + 20.f;
}

@end
