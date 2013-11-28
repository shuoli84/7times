//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <FlatUIKit/UIColor+FlatUI.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import "IPhoneViewController.h"
#import "Word.h"
#import "UIView+FindFirstResponder.h"
#import "Flurry.h"
#import "UIAlertView+BlocksKit.h"
#import "WordDetailViewController.h"
#import "WordTableViewCell.h"
#import "UIBarButtonItem+flexibleSpaceItem.h"
#import "Word+Util.h"

@interface IPhoneViewController() <UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;

@property (nonatomic, strong) NSString* model; //all or auto
@end

@implementation IPhoneViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.model = @"all";

    self.navigationController.navigationBar.tintColor = [UIColor greenSeaColor];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;

    self.declaration = [dec(@"root") $:@[
        dec(@"wordList", CGRectMake(0, 0, FVP(1.f), FVT(self.navigationController.toolbar.bounds.size.height)), self.wordListTableView = ^{
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];

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

    [self switchToWordList:NO];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];
    
    UIBarButtonItem *newWordButtonItem =
    [UIBarButtonItem.alloc
     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(addWordAction:)];

    typeof(self) __weak weakSelf = self;
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"All", @"全部"),
        NSLocalizedString(@"Todo", @"待背")
    ]];
    [segmentedControl addEventHandler:^(UISegmentedControl * sender) {
        if(sender.selectedSegmentIndex == 1){
            weakSelf.model = @"auto";
            [weakSelf switchToWordList:YES];
        }
        else{
            weakSelf.model = @"all";
            [weakSelf switchToWordList:NO];
        }
    } forControlEvents:UIControlEventValueChanged];

    segmentedControl.selectedSegmentIndex = 0;

    UIBarButtonItem *filterSwitch = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.leftBarButtonItem = filterSwitch;

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

-(void)switchToWordList:(BOOL)autoList{

    NSPredicate *predicate;
    if(autoList){
        predicate = [NSPredicate predicateWithFormat:@"(ignore == NULL OR ignore = %@) AND nextCheckTime <= %@ AND checkNumber > 0", [NSNumber numberWithBool:NO], [NSDate date]];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"ignore == NULL OR ignore = %@", [NSNumber numberWithBool:NO]];
    }

    self.wordFetchedResultsController = [Word
        MR_fetchAllSortedBy:@"lastCheckTime"
                  ascending:NO
              withPredicate:predicate
                    groupBy:nil
                   delegate:self];

    if(autoList){
        [self.wordFetchedResultsController.fetchRequest setSortDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"lastCheckTime" ascending:NO],
            [NSSortDescriptor sortDescriptorWithKey:@"source" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES],
        ]];
    }
    else{
        [self.wordFetchedResultsController.fetchRequest setSortDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"source" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES],
        ]];
    }

    [self.wordFetchedResultsController performFetch:nil];

    [self.wordListTableView reloadData];
    
    [self updateTitle];
}

-(void)addWord:(NSString*)word{
    word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(word.length == 0){
        [UIAlertView alertViewWithTitle:@"Failed to add" message:@"No letter contained"];
        return;
    }

    Word *wordRecord = [Word MR_createEntity];

    wordRecord.word = word;
    wordRecord.added = [NSDate date];
    wordRecord.source = @"0"; //Manual added one with 0 source to get better sort order
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
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
    
    [self updateTitle];
}

-(void)updateTitle{
    if([self.model isEqualToString:@"all"]){
        self.title = [NSString stringWithFormat:NSLocalizedString(@"all (%d)", @"all (%d)"), self.wordFetchedResultsController.fetchedObjects.count];
    }
    else{
        self.title = [NSString stringWithFormat:NSLocalizedString(@"todo (%d)", @"todo (%d)"), self.wordFetchedResultsController.fetchedObjects.count];
    }
}

- (IBAction)addWordAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewWord_Title", @"New Word") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
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
    typeof(self) __weak weakSelf = self;
    cell.showDefinitionBlock = ^(NSString *w){
        UIReferenceLibraryViewController *referenceLibraryViewController = [UIReferenceLibraryViewController.alloc initWithTerm:w];
        [weakSelf presentViewController:referenceLibraryViewController animated:YES completion:nil];
    };
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
        if([self.model isEqualToString:@"all"]){
            word.ignore = @(YES);
        }
        else{
            [word checkItNow];
        }

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.model isEqualToString:@"all"]){
        return NSLocalizedString(@"Ignore", @"Ignore");
    }
    else if([self.model isEqualToString:@"auto"]) {
        return @"记住了";
    }

    return nil;
}
@end