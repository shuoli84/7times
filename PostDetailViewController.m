//
// Created by Li Shuo on 13-11-22.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <FlatUIKit/UIColor+FlatUI.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import "PostDetailViewController.h"
#import "Post.h"
#import "TSMiniWebBrowser.h"
#import "NSURL+QueryString.h"

@interface PostDetailViewController()

@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextView *bodyTextView;
@end

@implementation PostDetailViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    typeof(self) __weak weakSelf = self;
    self.declaration = [dec(@"root") $:@[
        dec(@"titleLabel", CGRectMake(0, 0, FVP(1.f), 200), self.textView = ^{
            UITextView *titleTextView = [[UITextView alloc]init];
            titleTextView.font = [UIFont boldSystemFontOfSize:22];
            titleTextView.editable = NO;
            return titleTextView;
        }()),
        dec(@"bodyLabel", CGRectMake(0, FVAfter, FVP(1.f), FVTillEnd), self.bodyTextView = ^{
            UITextView *bodyTextView = [[UITextView alloc]init];
            bodyTextView.font = [UIFont systemFontOfSize:20];
            bodyTextView.editable = NO;
            return bodyTextView;
        }()),
        [dec(@"buttonContainer", CGRectMake(FVCenter, FVT(100), 250, 50)) $:@[
            dec(@"markAsRead", CGRectMake(0, 0, FVP(0.4), FVP(1.f)), ^{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor greenSeaColor];
                [button setTitle:@"已读" forState:UIControlStateNormal];
                [button addEventHandler:^(id sender) {
                    weakSelf.post.checked = [NSNumber numberWithBool:YES];
                    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
                return button;
            }()),
            dec(@"openFromBrowser", CGRectMake(FVAutoTail, 0, FVP(0.4), FVP(1.f)), ^{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor peterRiverColor];
                [button setTitle:@"原文" forState:UIControlStateNormal];
                [button addEventHandler:^(id sender) {
                    NSURL *url = [NSURL URLWithString:weakSelf.post.url];
                    if (url.dictionaryForQueryString[@"url"]) {
                        url = [NSURL URLWithString:url.dictionaryForQueryString[@"url"]];
                        NSLog(@"Get real url:%@", url.absoluteString);
                    }

                    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", url.absoluteString]];

                    TSMiniWebBrowser *browser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                    browser.mode = TSMiniWebBrowserModeNavigation;
                    [weakSelf.navigationController pushViewController:browser animated:YES];
                } forControlEvents:UIControlEventTouchUpInside];
                return button;
            }() ),
        ]],
    ]];

    [self.declaration setupViewTreeInto:self.view];

    self.textView.text = self.post.title;
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    CGRect frame = CGRectMake(0, 0, FVP(1.f), size.height);
    [self.declaration declarationByName:@"titleLabel"].unExpandedFrame = frame;
    [self.declaration updateViewFrame];
    self.bodyTextView.text = self.post.summary;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration resetLayout];
    [self.declaration updateViewFrame];
}
@end