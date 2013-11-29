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
#import "Flurry.h"
#import "UIAlertView+BlocksKit.h"
#import "WordDetailViewController.h"
#import "WordTableViewCell.h"
#import "UIBarButtonItem+flexibleSpaceItem.h"
#import "Word+Util.h"
#import "Binding.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "SLSharedConfig.h"
#import "Wordlist.h"
#import "WordListViewController.h"

@interface IPhoneViewController() <UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) UISegmentedControl *listSegmentedControl;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;

@property (nonatomic, strong) NSString* model; //all or auto

@property (nonatomic, strong) Binding* modelChangeBind;

@end

@implementation IPhoneViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.model = @"all";

    self.navigationController.navigationBar.tintColor = [UIColor greenSeaColor];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;

    self.navigationController.toolbar.barTintColor = nil;
    self.navigationController.toolbar.translucent = YES;

    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;

    self.declaration = [dec(@"root") $:@[
        dec(@"wordList", CGRectMake(0, 0, FVP(1.f), FVTillEnd), self.wordListTableView = ^{
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

    typeof(self) __weak weakSelf = self;
    UIBarButtonItem *wordListBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Word List", @"Word List") style:UIBarButtonItemStylePlain handler:^(id sender) {
        WordListViewController *wordListViewController = [[WordListViewController alloc] init];
        [weakSelf.navigationController pushViewController:wordListViewController animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = wordListBarItem;

    UIBarButtonItem *newWordButtonItem = [UIBarButtonItem.alloc
     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(addWordAction:)];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"All", @"全部"),
        NSLocalizedString(@"Todo", @"待背")
    ]];

    self.listSegmentedControl = segmentedControl;

    [segmentedControl addEventHandler:^(UISegmentedControl * sender) {
        if(sender.selectedSegmentIndex == 1){
            weakSelf.model = @"auto";
        }
        else{
            weakSelf.model = @"all";
        }
    } forControlEvents:UIControlEventValueChanged];

    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;

    [self
     setToolbarItems:@[
         [UIBarButtonItem flexibleSpaceItem],
         newWordButtonItem,
         [UIBarButtonItem flexibleSpaceItem],
     ]];

    self.modelChangeBind = binding(self, @"model", ^(NSObject *value){
        NSLog(@"Binding called");
        NSString* model = (NSString*)value;
        if([model isEqualToString:@"auto"]){
            [weakSelf switchToWordList:YES];

            UIBarButtonItem *pickWordsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+25" style:UIBarButtonItemStylePlain handler:^(id sender) {
                UIActionSheet *actionSheet = [UIActionSheet.alloc initWithTitle:NSLocalizedString(@"addWordFromList", @"从词库添加单词") delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"giveup", @"放弃") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"next", @"顺序"), NSLocalizedString(@"random", @"随机"), nil];
                [actionSheet showFromToolbar:weakSelf.navigationController.toolbar];

                return;
            }];

            [weakSelf setToolbarItems:@[
                [UIBarButtonItem flexibleSpaceItem],
                pickWordsButtonItem,
                [UIBarButtonItem flexibleSpaceItem],
            ] animated:YES];

        }
        else if([model isEqualToString:@"all"]){
            [weakSelf switchToWordList:NO];

            [weakSelf setToolbarItems:@[
                [UIBarButtonItem flexibleSpaceItem],
                newWordButtonItem,
                [UIBarButtonItem flexibleSpaceItem],
            ] animated:YES];
        }
    });
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
    NSString *cacheName;
    if(autoList){
        predicate = [NSPredicate predicateWithFormat:@"(ignore = NULL OR ignore = NO) AND lists CONTAINS %@", [SLSharedConfig sharedInstance].todoList];
        cacheName = @"cache_todolist";
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"ignore = NULL OR ignore = NO"];
        cacheName = @"cache_all";
    }

    NSFetchRequest *fetchRequest = [Word MR_requestAllSortedBy:@"source,sortOrder,added" ascending:YES withPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    self.wordFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread] sectionNameKeyPath:nil cacheName:cacheName];
    [self.wordFetchedResultsController performFetch:nil];

    [self.wordListTableView reloadData];
    self.wordFetchedResultsController.delegate = self;
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
    NSString *todoTitle = [NSString stringWithFormat:NSLocalizedString(@"todo (%d)", @"todo (%d)"), [SLSharedConfig sharedInstance].todoList.words.count];

    [self.listSegmentedControl setTitle:todoTitle forSegmentAtIndex:1];

    if([self.model isEqualToString:@"all"]){
        NSString* title = [NSString stringWithFormat:NSLocalizedString(@"all (%d)", @"all (%d)"), self.wordFetchedResultsController.fetchedObjects.count];
        self.title = title;
        [self.listSegmentedControl setTitle:title forSegmentAtIndex:0];
    }
    else{
        self.title = todoTitle;
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
            [[SLSharedConfig sharedInstance].todoList removeWordsObject:word];
        }

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.model isEqualToString:@"all"]){
        return NSLocalizedString(@"Ignore", @"Ignore");
    }
    else if([self.model isEqualToString:@"auto"]) {
        return NSLocalizedString(@"Remebered", @"记住了");
    }

    return nil;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL random = NO;
    switch (buttonIndex){
        case 0:
            break;
        case 1:
            random = YES;
            break;
        case 2:
            return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(ignore = NULL OR ignore = FALSE) AND checkNumber = 0 AND (NONE lists.name = 'todo' OR lists.@count = 0)"];

    NSFetchRequest *fetchRequest = [Word MR_requestAllSortedBy:@"source,sortOrder,added" ascending:YES withPredicate:predicate];

    if(!random){
        [fetchRequest setFetchLimit:25];
    }

    NSError *err;
    NSArray *all = [[NSManagedObjectContext MR_contextForCurrentThread] executeFetchRequest:fetchRequest error:&err];

    if(all == nil){
        NSLog(@"Error: %@", err.localizedDescription);
    }

    if(all.count == 0){
        typeof(self) __weak weakSelf =  self;
        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"No more new words", @"No more new words") message:NSLocalizedString(@"There is no more new words, add some from word list", @"There is no more new words, add some from word list") cancelButtonTitle:NSLocalizedString(@"Got It", @"Got It") otherButtonTitles:@[NSLocalizedString(@"Word List", @"Word List")] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 1){
                WordListViewController *wordListViewController = [[WordListViewController alloc] init];
                [weakSelf.navigationController pushViewController:wordListViewController animated:YES];
            }
        }];
    }

    if(all){
        NSMutableSet *mutableSet = [NSMutableSet set];
        if(!random){
            [mutableSet addObjectsFromArray:all];
        }
        else{
            int count = all.count;

            for(int i = 0; i < MIN(25, count); i++){
                uint index = arc4random() % count;
                [mutableSet addObject:all[index]];
            }
        }

        [[SLSharedConfig sharedInstance].todoList addWords:mutableSet];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}
@end