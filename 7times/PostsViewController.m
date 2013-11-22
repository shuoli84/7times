//
//  PostsViewController.m
//  7times
//
//  Created by Li Shuo on 13-11-21.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <SLFlexibleView/FVDeclaration.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import <BlocksKit/NSObject+AssociatedObjects.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import <TSMiniWebBrowser/TSMiniWebBrowser.h>
#import "PostsViewController.h"
#import "PostManager.h"
#import "PostDownloader.h"
#import "Post.h"
#import "Word+Util.h"
#import "SLSharedConfig.h"
#import "NSURL+QueryString.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "PostDetailTableViewCell.h"

@interface PostsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FVDeclaration* declaration;

@end

@implementation PostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.itemListTableView.rowHeight = self.view.bounds.size.height;
    self.itemListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.itemListTableView.allowsSelection = NO;
    self.itemListTableView.pagingEnabled = YES;

    [self.itemListTableView registerClass:[PostDetailTableViewCell class] forCellReuseIdentifier:@"cell"];

    typeof (self) __weak weakSelf = self;

    [SLSharedConfig.sharedInstance.postManager setPostChangeBlock:^(PostManager *postManager, Post *post, int index, int newIndex) {
        if (newIndex < 0) {
            [weakSelf.itemListTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [weakSelf.itemListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];

    [SLSharedConfig.sharedInstance.postManager start];

    [[SLSharedConfig sharedInstance].postDownloader startWithShouldBeginBlock:^{
        return SLSharedConfig.sharedInstance.postManager.needNewPost;
    }                                oneWordFinish:^(NSString *word) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Word* wordRecord = [Word MR_findFirstByAttribute:@"word" withValue:word];
            [SLSharedConfig.sharedInstance.postManager loadPostForWord:wordRecord];
        });
    } completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SLSharedConfig.sharedInstance.postManager loadPost];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [SLSharedConfig sharedInstance].postManager.postCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostDetailTableViewCell *cell = (PostDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    typeof(self) __weak weakSelf = self;
    static char postKey;
    static char key;
    UITableViewCell *__weak weakCell = cell;
    UITableView *__weak weakTableView = tableView;

    dec(@"doneButton", CGRectMake(0, FVSameAsPrev, FVT(156), 50), ^{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addEventHandler:^(id sender) {
            NSIndexPath *idx = [weakTableView indexPathForCell:weakCell];
            if (idx != nil) {
                [[SLSharedConfig sharedInstance].postManager markPostAsReadAtIndex:idx];
            }
        }      forControlEvents:UIControlEventTouchUpInside];

        return button;
    }());
        dec(@"lookupButton", CGRectMake(FVA(2), FVSameAsPrev, 50, FVTillEnd), ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"?" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            button.tag = 108;

            [button addEventHandler:^(id sender) {
                NSIndexPath *idx = [weakTableView indexPathForCell:weakCell];
                if (idx != nil) {
                    Post *p = (Post *) [weakCell associatedValueForKey:&postKey];
                    Word *w = p.word;

                    UIReferenceLibraryViewController *dictionViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:w.word];
                    [weakSelf presentViewController:dictionViewController animated:YES   completion:nil];
                }
            }      forControlEvents:UIControlEventTouchUpInside];
            return button;
        }());
        dec(@"openInBrowserButton", CGRectMake(FVT(50), FVSameAsPrev, 50, FVTillEnd), ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@">" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            button.tag = 109;

            [button addEventHandler:^(id sender) {
                NSIndexPath *idx = [weakTableView indexPathForCell:weakCell];
                if (idx != nil) {
                    Post *p = (Post *) [weakCell associatedValueForKey:&postKey];
                    NSURL *url = [NSURL URLWithString:p.url];
                    if (url.dictionaryForQueryString[@"url"]) {
                        url = [NSURL URLWithString:url.dictionaryForQueryString[@"url"]];
                        NSLog(@"Get real url:%@", url.absoluteString);
                    }

                    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", url.absoluteString]];

                    TSMiniWebBrowser *browser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                    browser.mode = TSMiniWebBrowserModeModal;
                    [weakSelf presentViewController:browser animated:YES completion:nil];
                }
            }      forControlEvents:UIControlEventTouchUpInside];
            return button;
    }());
    Post *post = [[SLSharedConfig sharedInstance].postManager postForIndexPath:indexPath];
    cell.post = post;

    Word *word = post.word;
    UIColor *wordColor;
    int checkNumber = word.checkNumber.integerValue;
    if (word.lastCheckExpired) {
        wordColor = [[SLSharedConfig sharedInstance] colorForCount:checkNumber];
    }
    else if (checkNumber >= 1) {
        wordColor = [[SLSharedConfig sharedInstance] colorForCount:checkNumber - 1];
    }
    else {
        wordColor = [UIColor blackColor];
    }

    UIButton *dismissButton = (UIButton *) [cell viewWithTag:107];
    dismissButton.backgroundColor = wordColor;
    [dismissButton setTitle:word.word forState:UIControlStateNormal];

    UIButton *lookUpButton = (UIButton *) [cell viewWithTag:108];
    lookUpButton.backgroundColor = wordColor;

    UIButton *openLinkButton = (UIButton *) [cell viewWithTag:109];
    openLinkButton.backgroundColor = wordColor;

    UIButton *backButton = (UIButton *) [cell viewWithTag:110];
    backButton.backgroundColor = wordColor;


    UITextView *label = (UITextView *) [cell viewWithTag:101];
    label.text = post.title;

    FVDeclaration *declaration = (FVDeclaration *) [cell associatedValueForKey:&key];
    declaration.unExpandedFrame = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
    [declaration resetLayout];
    [declaration updateViewFrame];

    [label sizeToFit];
    [declaration declarationByName:@"title"].unExpandedFrame = CGRectMake(0, FVA(5), FVT(5), label.frame.size.height);

    [declaration resetLayout];
    [declaration updateViewFrame];

    return cell;
}

@end
