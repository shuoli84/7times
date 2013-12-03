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
#import "UIFont+Util.h"

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

    if([post.title rangeOfString:@"<b>"].location != NSNotFound){
        NSRange range = [post.title rangeOfString:@"<b>"];
        NSRange range1 = [post.title rangeOfString:@"</b>"];
        NSRange rangeWholeTag = NSMakeRange(range.location, range1.location - range.location + range1.length);
        NSRange rangeContent = NSMakeRange(range.location + range.length, range1.location - range.location - range.length);
        NSString *content = [post.title substringWithRange:rangeContent];
        NSString *title = [post.title stringByReplacingCharactersInRange:rangeWholeTag withString:content];

        NSRange newRange = NSMakeRange(range.location, range1.location - range.location - range.length);
        UIFont *boldFont = [UIFont boldSystemFontOfSize:UIFont.preferredFontSize];
        UIFont *regularFont = [UIFont systemFontOfSize:UIFont.preferredFontSize];

        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
            boldFont, NSFontAttributeName,
            nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
            regularFont, NSFontAttributeName, nil];

        NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:title
                                                   attributes:subAttrs];
        [attributedText setAttributes:attrs range:newRange];

        [self.textLabel setAttributedText:attributedText];
    }
    else{
        self.textLabel.text = post.title;
    }
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
