//
// Created by Li Shuo on 13-11-21.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import "PostBriefTableViewCell.h"
#import "WordDetailViewController.h"
#import "Word.h"
#import "Post.h"
#import "UIColor+FlatUI.h"
#import "PostDetailViewController.h"
#import "SLSharedConfig.h"
#import "PostDownloader.h"
#import "SVProgressHUD.h"
#import "WeiboSDK.h"
#import "UIBarButtonItem+flexibleSpaceItem.h"
#import "Check.h"
#import "Word+Util.h"

@interface WordDetailViewController() <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *postsFetchedResultsController;
@property (nonatomic, strong) FVDeclaration *declare;

@property (nonatomic, strong) UITableView *postsTable;
@property (nonatomic, strong) UIButton *dictionaryButton;

@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, strong) NSMutableDictionary *postHeightCache;
@end

@implementation WordDetailViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.postHeightCache = [NSMutableDictionary dictionaryWithCapacity:30];

    self.title = self.word.word;

    self.view.backgroundColor = [UIColor whiteColor];

    self.postsFetchedResultsController = [Post MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"word=%@", self.word] groupBy:nil delegate:self];
    
    self.declare = [dec(@"root", CGRectZero) $:@[
        dec(@"Posts", CGRectMake(0, FVA(0), FVP(1.f), FVTillEnd), self.postsTable = ^{
            UITableView *tableView = [[UITableView alloc]
                                      initWithFrame:CGRectZero
                                      style:UITableViewStylePlain];
            [tableView registerClass:[PostBriefTableViewCell class] forCellReuseIdentifier:@"cell"];
            tableView.delegate = self;
            tableView.dataSource = self;
            return tableView;
        }()),
    ]];

    [self.declare setupViewTreeInto:self.view];

    self.navigationController.toolbar.tintColor = [UIColor greenSeaColor];
    UIBarButtonItem *dictionaryItem = [UIBarButtonItem.alloc
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                       target:self
                                       action:@selector(lookupWord:)];

    UIBarButtonItem *loadNewsItem = [UIBarButtonItem.alloc
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                    target:self action:@selector(loadNews:)];

    UIBarButtonItem *shareItem = [UIBarButtonItem.alloc
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self action:@selector(share:)];

    [self setToolbarItems:@[
                            [UIBarButtonItem flexibleSpaceItem],
                            dictionaryItem,
                            [UIBarButtonItem flexibleSpaceItem],
                            loadNewsItem,
                            [UIBarButtonItem flexibleSpaceItem],
                            shareItem,
                            [UIBarButtonItem flexibleSpaceItem],
                            ]];
    self.navigationController.toolbarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.startTime = [NSDate date];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSDate *now = [NSDate date];
    NSTimeInterval period = now.timeIntervalSince1970 - self.startTime.timeIntervalSince1970;
    if(period > 5.f){
        NSLog(@"The word showed longer than 5 seconds, treat this as a valid view");

        if(self.word.lastCheckExpired){
            NSLog(@"The last check is expired, mark this as a new check");
            Check *check = [Check MR_createEntity];
            check.date = now;
            [self.word addCheckHelper:check];

            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        }
        else{
            NSLog(@"The last check still valid, so this can't be marked as a new check");
        }
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declare.unExpandedFrame = self.view.bounds;
    [self.declare resetLayout];
    [self.declare updateViewFrame];
}

-(void)lookupWord:(id) sender{
    UIReferenceLibraryViewController *dictionViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:self.word.word];
    [self presentViewController:dictionViewController animated:YES completion:nil];
}

-(void)loadNews:(id) sender{
    Word *w = self.word;
    [SVProgressHUD showWithStatus:@"下载中" maskType:SVProgressHUDMaskTypeGradient];
    [SLSharedConfig.sharedInstance.postDownloader downloadForWord:w.word completion:^{
        [SVProgressHUD dismiss];
    }];
}

-(void)share:(id) sender{
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"在背单词%@ 来自7times", self.word.word];
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

#pragma mark TableViewDelegate & DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.postHeightCache[indexPath]){
        return [self.postHeightCache[indexPath] integerValue];
    }

    Post* post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    PostBriefTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.post = post;

    self.postHeightCache[indexPath] = @(cell.cellHeight);

    return cell.cellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.postsFetchedResultsController.sections[0];
    return sectionInfo.numberOfObjects;
}

-(UITableViewCell*)tableView:(UITableView *)tableView
       cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostBriefTableViewCell *cell = (PostBriefTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Post* post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    cell.post = post;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
    postDetailViewController.post = post;
    [self.navigationController pushViewController:postDetailViewController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Post *post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
        post.checked = [NSNumber numberWithBool:YES];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"已读";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark NSFetchedResultsDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.postsTable beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.postsTable endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if([controller isEqual:self.postsFetchedResultsController]){
        UITableView *tableView = self.postsTable;
        switch (type){
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }
}


@end