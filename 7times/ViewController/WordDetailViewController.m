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
#import "UIBarButtonItem+flexibleSpaceItem.h"
#import "Check.h"
#import "Word+Util.h"

@interface WordDetailViewController() <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *postsFetchedResultsController;
@property (nonatomic, strong) FVDeclaration *declare;

@property (nonatomic, strong) UITableView *postsTable;

@property (nonatomic, strong) NSMutableDictionary *postHeightCache;

@property (nonatomic, strong) UIReferenceLibraryViewController *wordReferenceViewController;
@end

@implementation WordDetailViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.postHeightCache = [NSMutableDictionary dictionaryWithCapacity:30];

    self.title = self.word.word;

    self.view.backgroundColor = [UIColor whiteColor];

    self.postsFetchedResultsController = [Post MR_fetchAllSortedBy:@"source,date" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"word=%@", self.word] groupBy:@"source" delegate:self];
    
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

    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.wordReferenceViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:weakSelf.word.word];
    });
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declare.unExpandedFrame = self.view.bounds;
    [self.declare resetLayout];
    [self.declare updateViewFrame];
}

-(void)lookupWord:(id) sender{
    if(self.wordReferenceViewController != nil){
        [self presentViewController:self.wordReferenceViewController animated:YES completion:nil];
    }
    else{
        UIReferenceLibraryViewController *dictionViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:self.word.word];
        [self presentViewController:dictionViewController animated:YES completion:nil];
    }
}

-(void)loadNews:(id) sender{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading", @"Downloading") maskType:SVProgressHUDMaskTypeGradient];
    [SLSharedConfig.sharedInstance.postDownloader downloadForWord:self.word completion:^{
        [SVProgressHUD dismiss];
    }];
}

-(void)share:(id) sender{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"RememberingWord", @"在背单词%@ 来自7times"), self.word.word];

    NSMutableArray *sharingItems = [NSMutableArray array];
    [sharingItems addObject:message];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark TableViewDelegate & DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Post* post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];

    if(self.postHeightCache[post.objectID]){
        return [self.postHeightCache[post.objectID] integerValue];
    }

    PostBriefTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.post = post;

    self.postHeightCache[post.objectID] = @(cell.cellHeight);

    return cell.cellHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.postsFetchedResultsController.sections.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.postsFetchedResultsController.sections[section];
    return NSLocalizedString(sectionInfo.name, @"section name");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.postsFetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

-(UITableViewCell*)tableView:(UITableView *)tableView
       cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostBriefTableViewCell *cell = (PostBriefTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Post* post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    cell.post = post;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    PostDetailViewController *postDetailViewController = [[PostDetailViewController alloc] init];
    postDetailViewController.post = post;
    postDetailViewController.wordReferenceViewController = self.wordReferenceViewController;
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

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if([controller isEqual:self.postsFetchedResultsController]){
        UITableView *tableView = self.postsTable;

        switch (type){
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }
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