//
// Created by Li Shuo on 13-11-22.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <TSMiniWebBrowser/TSMiniWebBrowser.h>
#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "PostDetailTableViewCell.h"
#import "Post.h"
#import "Word.h"
#import "SLSharedConfig.h"


@interface PostDetailTableViewCell()

@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UITextView *bodyTextView;

@property (nonatomic, strong) TTTTimeIntervalFormatter *timeFormmater;
@property (nonatomic, strong) FVDeclaration* declaration;

@end

@implementation PostDetailTableViewCell {

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.declaration = [dec(@"cell") $:@[
            [dec(@"topping", CGRectMake(0, 0, FVP(1), 25)) $:@[
                dec(@"source", CGRectMake(5, FVCenter, FVFill, 20), self.topTitle = ^{
                    UILabel *label = [[UILabel alloc] init];
                    label.textColor = [UIColor colorWithRed:1.f green:128 / 255.f blue:0.f alpha:1.f];
                    label.font = [UIFont boldSystemFontOfSize:15];
                    label.backgroundColor = [UIColor clearColor];
                    return label;
                }()),
            ]],
            [dec(@"container", CGRectMake(0, FVA(0), FVP(1.f), FVT(75)), ^{
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = [UIColor colorWithRed:236 / 255.f green:240 / 255.f blue:241 / 255.f alpha:1.f];
                return view;
            }()) $:@[
                dec(@"title", CGRectMake(0, FVA(5), FVT(5), 100), self.titleTextView = ^{
                    UITextView *label = [[UITextView alloc] init];
                    label.backgroundColor = [UIColor clearColor];

                    label.editable = NO;
                    label.font = [UIFont systemFontOfSize:25];
                    label.scrollEnabled = NO;
                    return label;
                }()),
                dec(@"datetime", CGRectMake(5, FVA(5), FVP(1), 20), self.dateLabel = ^{
                    UILabel *label = [[UILabel alloc] init];
                    label.backgroundColor = [UIColor clearColor];
                    label.font = [UIFont boldSystemFontOfSize:15];
                    label.textColor = [UIColor colorWithRed:127 / 255.f green:140 / 255.f blue:141 / 255.f alpha:1.f];
                    return label;
                }()),
                dec(@"summary", CGRectMake(5, FVA(0), FVT(5), FVTillEnd), self.bodyTextView = ^{
                    UITextView *textView = [[UITextView alloc] init];
                    textView.editable = NO;
                    textView.font = [UIFont systemFontOfSize:20];
                    textView.backgroundColor = [UIColor clearColor];
                    return textView;
                }()),
            ]],

        ]];

        [self.declaration setupViewTreeInto:self];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.declaration.unExpandedFrame = self.bounds;
    [self.declaration resetLayout];
    [self.declaration updateViewFrame];
}

-(void)setPost:(Post *)post {
    _post = post;

    self.topTitle.text = post.source;
    self.titleTextView.text = post.title;
    self.dateLabel.text = [SLSharedConfig.sharedInstance.timeFormmater stringForTimeInterval:[post.date timeIntervalSinceNow]];

    self.bodyTextView.text = post.summary;
}
@end