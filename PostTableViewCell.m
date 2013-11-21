//
//  PostTableViewCell.m
//  7times
//
//  Created by Li Shuo on 13-11-21.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "PostTableViewCell.h"
#import "Post.h"

@implementation PostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPost:(Post *)post{
    _post = post;
    self.textLabel.text = post.title;

    if(post.checked.boolValue){
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }

    CGSize titleSize = [self.textLabel sizeThatFits:self.bounds.size];
    _cellHeight = titleSize.height + 20.f;
}

@end
