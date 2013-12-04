//
// Created by Li Shuo on 13-12-1.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <FlatUIKit/UIColor+FlatUI.h>
#import <MessageUI/MessageUI.h>
#import <iRate/iRate.h>
#import "MenuViewController.h"
#import "Wordlist.h"
#import "WordListViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "WordsViewController.h"
#import "MFMessageComposeViewController+BlocksKit.h"
#import "ConfigViewController.h"
#import "SLSharedConfig.h"


@interface MenuViewController() <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSFetchedResultsController *wordListFetchedResultsController;
@end

@implementation MenuViewController {

}

-(void)viewDidLoad{
    [super viewDidLoad];

    self.menuItems = @[
       // NSLocalizedString(@"Setting", @"Setting"),
        NSLocalizedString(@"Comment", @"Comment"),
        NSLocalizedString(@"Review", @"Review")
    ];

    self.wordListFetchedResultsController = [Wordlist MR_fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"NOT (name BEGINSWITH %@)", @"todo"] sortedBy:@"sortOrder" ascending:YES delegate:self];

    self.view.backgroundColor = [UIColor greenSeaColor];
    self.wordListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.wordListTableView.dataSource = self;
    self.wordListTableView.delegate = self;

    [self.wordListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    [self.view addSubview:self.wordListTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        id<NSFetchedResultsSectionInfo> sectionInfo = self.wordListFetchedResultsController.sections[0];
        return sectionInfo.numberOfObjects + 1;
    }
    else{
        return self.menuItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(indexPath.section == 0){
        if(indexPath.row >= self.wordListFetchedResultsController.fetchedObjects.count){
            cell.textLabel.text = NSLocalizedString(@"Load", @"Load");
        }
        else{
            Wordlist *wordlist = self.wordListFetchedResultsController.fetchedObjects[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(wordlist.name, @"wordlist name"), [wordlist.words count]];
        }
    }
    else{
        cell.textLabel.text = self.menuItems[indexPath.row];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return NSLocalizedString(@"Word list", @"Word list");
    }
    else{
        return NSLocalizedString(@"Tools", @"Tools");
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    typeof(self) __weak weakSelf = self;
    if(indexPath.section == 0){
        if(indexPath.row >= self.wordListFetchedResultsController.fetchedObjects.count){
            NSLog(@"Load from word list view controller");
            WordListViewController *wordListViewController = [[WordListViewController alloc] init];
            [self presentViewController:wordListViewController animated:YES completion:nil];
        }
        else{
            Wordlist *wordlist = self.wordListFetchedResultsController.fetchedObjects[indexPath.row];

            WordsViewController *newWordsViewController = [[WordsViewController alloc] init];
            newWordsViewController.wordList = wordlist;
            newWordsViewController.enableTodoMode = YES;
            if([[SLSharedConfig sharedInstance].needsPostList.objectID isEqual:wordlist.objectID]){
                NSLog(@"This only served as an indicator");
                return;
            }
            if([[SLSharedConfig sharedInstance].manualList.objectID isEqual:wordlist.objectID]){
                newWordsViewController.enableTodoMode = NO;
            }
            UINavigationController *newNavigationController = [[UINavigationController alloc] initWithRootViewController:newWordsViewController];
            [self.mm_drawerController setCenterViewController:newNavigationController];
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        }
    }
    else{
        if(indexPath.row == 0){
            MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
            if([MFMessageComposeViewController canSendText]){
                messageComposeViewController.recipients = @[@"menic84@msn.com"];
                [messageComposeViewController setCompletionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult result) {
                    [controller dismissViewControllerAnimated:YES completion:nil];
                }];
                [self presentViewController:messageComposeViewController animated:YES completion:^{
                    [weakSelf.mm_drawerController closeDrawerAnimated:NO completion:nil];
                }];
            }
            else{
                NSLog(@"Not able to send imessage");
            }
        }
        else if(indexPath.row == 1){
            [[iRate sharedInstance] openRatingsPageInAppStore];
            [weakSelf.mm_drawerController closeDrawerAnimated:YES completion:nil];
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.wordListTableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.wordListTableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if([controller isEqual:self.wordListFetchedResultsController]){
        UITableView *tableView = self.wordListTableView;
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