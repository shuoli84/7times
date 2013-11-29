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
#import "Word+Util.h"
#import "Check.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "UIBarButtonItem+flexibleSpaceItem.h"

@interface PostDetailViewController()

@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextView *bodyTextView;

@property (nonatomic, strong) NSDate *startTime;
@end

@implementation PostDetailViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    typeof(self) __weak weakSelf = self;
    self.declaration = [dec(@"root") $:@[
        dec(@"titleLabel", CGRectMake(0, 0, FVP(1.f), 200), self.textView = ^{
            UITextView *titleTextView = [[UITextView alloc]init];
            titleTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            titleTextView.editable = NO;
            titleTextView.scrollEnabled = NO;
            return titleTextView;
        }()),
        dec(@"bodyLabel", CGRectMake(0, FVAfter, FVP(1.f), FVTillEnd), self.bodyTextView = ^{
            UITextView *bodyTextView = [[UITextView alloc]init];
            bodyTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            bodyTextView.editable = NO;
            bodyTextView.scrollEnabled = YES;
            return bodyTextView;
        }()),
    ]];

    [self.declaration setupViewTreeInto:self.view];

    self.textView.text = self.post.title;
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    CGRect frame = CGRectMake(0, 0, FVP(1.f), size.height);
    [self.declaration declarationByName:@"titleLabel"].unExpandedFrame = frame;
    [self.declaration updateViewFrame];
    self.bodyTextView.text = self.post.summary;

    UIBarButtonItem *lookupButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch handler:^(id sender) {
        if(weakSelf.wordReferenceViewController){
            [weakSelf presentViewController:weakSelf.wordReferenceViewController animated:YES completion:nil];
        }
        else{
            UIReferenceLibraryViewController *referenceLibraryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:self.post.word.word];
            [weakSelf presentViewController:referenceLibraryViewController animated:YES completion:nil];
        }
    }];

    UIBarButtonItem *openLinkButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay handler:^(id sender) {
        NSURL *url = [NSURL URLWithString:weakSelf.post.url];
        if (url.dictionaryForQueryString[@"url"]) {
            url = [NSURL URLWithString:url.dictionaryForQueryString[@"url"]];
            NSLog(@"Get real url:%@", url.absoluteString);
        }

        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", url.absoluteString]];

        TSMiniWebBrowser *browser = [[TSMiniWebBrowser alloc] initWithUrl:url];
        browser.mode = TSMiniWebBrowserModeNavigation;
        [weakSelf.navigationController pushViewController:browser animated:YES];
        // hide the bar, cause the browser vc has its own bar
        weakSelf.navigationController.toolbarHidden = YES;
    }];

    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction handler:^(id sender) {
        NSURL *url = [NSURL URLWithString:weakSelf.post.url];
        if (url.dictionaryForQueryString[@"url"]){
            url = [NSURL URLWithString:url.dictionaryForQueryString[@"url"]];
        }

        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"TheArticleGoodForWord", @"这篇文章%@ %@\n有助于背单词%@"), weakSelf.post.title, url.absoluteString, weakSelf.post.word.word];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
            initWithActivityItems:@[message]
            applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }];

    [self setToolbarItems:@[
        [UIBarButtonItem flexibleSpaceItem],
        lookupButtonItem,
        [UIBarButtonItem flexibleSpaceItem],
        openLinkButtonItem,
        [UIBarButtonItem flexibleSpaceItem],
        shareButtonItem,
        [UIBarButtonItem flexibleSpaceItem],
    ]];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration resetLayout];
    [self.declaration updateViewFrame];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = NO; // Force to show the bar cause we need it
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.startTime = [NSDate date];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    NSTimeInterval period = [NSDate date].timeIntervalSince1970 - self.startTime.timeIntervalSince1970;
    if(period > 5.f){
        NSLog(@"Period is long enough to mark this post as read");
        self.post.checked = [NSNumber numberWithBool:YES];

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}
@end