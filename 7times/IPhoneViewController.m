//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/NSObject+AssociatedObjects.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import <FlatUIKit/UIColor+FlatUI.h>
#import "IPhoneViewController.h"
#import "Word.h"
#import "DotView.h"
#import "PostManager.h"
#import "Post.h"
#import "SLSharedConfig.h"
#import "UIView+FindFirstResponder.h"
#import "Word+Util.h"
#import "Flurry.h"
#import "TSMiniWebBrowser.h"
#import "NSURL+QueryString.h"
#import "PostDownloader.h"
#import "WordListViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "WordDetailViewController.h"
#import "WordTableViewCell.h"
#import "UIBarButtonItem+flexibleSpaceItem.h"
#import "AccountViewController.h"

@interface IPhoneViewController() <UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;
@end

@implementation IPhoneViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.toolbarHidden = NO;
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor greenSeaColor];
        self.navigationController.navigationBar.translucent = NO;
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor greenSeaColor];
    }

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    self.wordFetchedResultsController = [Word
                                         MR_fetchAllSortedBy:@"lastCheckTime"
                                         ascending:NO
                                         withPredicate:
                                         [NSPredicate predicateWithFormat:@"ignore == NULL OR ignore = %@", [NSNumber numberWithBool:NO]]
                                         groupBy:nil
                                         delegate:self];
    [self.wordFetchedResultsController.fetchRequest setSortDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"lastCheckTime" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"source" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES],
    ]];

    [self.wordFetchedResultsController performFetch:nil];

    self.declaration = [dec(@"root") $:@[
        dec(@"wordList", CGRectMake(0, 0, FVP(1.f), FVT(self.navigationController.toolbar.bounds.size.height)), ^{
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            self.wordListTableView = tableView;

            tableView.backgroundColor = [UIColor whiteColor];
            tableView.rowHeight = 48;
            tableView.allowsSelection = YES;

            [tableView registerClass:[WordTableViewCell class] forCellReuseIdentifier:@"cell"];
            tableView.dataSource = self;
            tableView.delegate = self;

            return tableView;
        }()),
    ]];

    [self.declaration setupViewTreeInto:self.view];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];
    
    UIBarButtonItem *newWordButtonItem =
    [UIBarButtonItem.alloc
     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(addWordAction:)];
    newWordButtonItem.tintColor = [UIColor greenSeaColor];
    
    [self
     setToolbarItems:@[
                       [UIBarButtonItem flexibleSpaceItem],
                       newWordButtonItem,
                       [UIBarButtonItem flexibleSpaceItem],
                       ]];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self.declaration resetLayout];
    CGRect bounds = self.view.bounds;
    self.declaration.unExpandedFrame = bounds;
    [self.declaration updateViewFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"The button index: %d", buttonIndex);
    if(buttonIndex == 1){
        NSString* word = [alertView textFieldAtIndex:0].text;
        [self addWord:word];

        [Flurry logEvent:@"Word_add" withParameters:@{
            @"word":word
        }];
    }
}

-(void)addWord:(NSString*)word{
    word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(word.length == 0){
        [UIAlertView alertViewWithTitle:@"Failed to add" message:@"No letter contained"];
        return;
    }

    Word *wordRecord = [Word MR_findFirstByAttribute:@"word" withValue:word];
    if(wordRecord){
        NSLog(@"Word already there, no need to create a new one");
        return;
    }

    wordRecord = [Word MR_createEntity];

    wordRecord.word = word;
    wordRecord.added = [NSDate date];
    wordRecord.source = @"0";
    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

    [SLSharedConfig.sharedInstance.postDownloader downloadForWord:word completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SLSharedConfig sharedInstance].postManager loadPostForWord:wordRecord];
        });
    }];
}

-(void)addWordMenuAction:(id)sender{
    UIView *firstResponder = [self.view firstResponder];
    [firstResponder copy:firstResponder];

    NSString *highlightedText = [UIPasteboard generalPasteboard].string;
    highlightedText = [highlightedText lowercaseString];
    NSLog(@"%@", highlightedText);
    [self addWord:highlightedText];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.wordListTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.wordListTableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if([controller isEqual:self.wordFetchedResultsController]){
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


- (IBAction)addWordAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewWord_Title", @"New Word") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)showAccountViewController:(id)sender {
    AccountViewController *accountViewController = AccountViewController.alloc.init;
    [self.navigationController pushViewController:accountViewController animated:YES];
}

#pragma mark UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.wordFetchedResultsController.sections[0];
    return sectionInfo.numberOfObjects;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WordTableViewCell *cell = (WordTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    Word* word = [self.wordFetchedResultsController objectAtIndexPath:indexPath];
    cell.word = word;
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath{
    Word* word = [self.wordFetchedResultsController objectAtIndexPath:indexPath];
    WordDetailViewController *wordDetailViewController = [[WordDetailViewController alloc] init];
    wordDetailViewController.word = word;
    [self.navigationController pushViewController:wordDetailViewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Word *word = [self.wordFetchedResultsController objectAtIndexPath:indexPath];
        word.ignore = @(YES);
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Ignore", @"Ignore");
}
@end