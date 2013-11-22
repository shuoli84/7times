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

@interface WordDetailViewController() <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSFetchedResultsController *postsFetchedResultsController;
@property (nonatomic, strong) FVDeclaration *declare;

@property (nonatomic, strong) UITableView *postsTable;
@end

@implementation WordDetailViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.word.word;

    self.view.backgroundColor = [UIColor whiteColor];

    self.postsFetchedResultsController = [Post MR_fetchAllSortedBy:@"date" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"word=%@", self.word] groupBy:nil delegate:self];

    self.declare = [dec(@"root", CGRectZero) $:@[
        dec(@"info", CGRectMake(0, 0, FVP(1.f), 150), ^{
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor greenSeaColor];
            return view;
        }()),
        dec(@"Posts", CGRectMake(0, FVA(0), FVP(1.f), FVFill), self.postsTable = ^{
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
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillDisappear:animated];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declare.unExpandedFrame = self.view.bounds;
    [self.declare resetLayout];
    [self.declare updateViewFrame];
}

#pragma mark TableViewDelegate & DataSource

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Post* post = [self.postsFetchedResultsController objectAtIndexPath:indexPath];
    PostBriefTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.post = post;
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
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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