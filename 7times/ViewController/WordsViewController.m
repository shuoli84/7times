//
// Created by Li Shuo on 13-9-16.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <FlatUIKit/UIColor+FlatUI.h>
#import "Wordlist.h"
#import <BlocksKit/UIControl+BlocksKit.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import "WordsViewController.h"
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
#import "WordListViewController.h"
#import "Wordlist+TodoList.h"
#import "PostDownloader.h"


@interface WordsViewController () <UIAlertViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) UISegmentedControl *listSegmentedControl;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;

@property (nonatomic, assign) RunningModel model; //all or auto

@property (nonatomic, strong) Binding* modelChangeBind;

@end

@implementation WordsViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    if(self.wordList == nil){
        self.wordList = [Wordlist MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"not name beginswith %@", @"todo"] sortedBy:@"sortOrder" ascending:YES];
        self.enableTodoMode = YES;
    }

    if(self.enableTodoMode){
        self.model = RunningModelTodo;
    }
    else{
        self.model = RunningModelAll;
    }

    self.navigationController.navigationBar.tintColor = [UIColor greenSeaColor];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;

    self.navigationController.toolbar.barTintColor = nil;
    self.navigationController.toolbar.translucent = YES;

    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;

    typeof(self) __weak weakSelf = self;
    UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"259-list.png"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [weakSelf.navigationController.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;

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

    if(self.enableTodoMode){
        [self switchToWordList:YES];
    }
    else{
        [self switchToWordList:NO];
    }

    UIBarButtonItem *newWordButtonItem = [UIBarButtonItem.alloc
     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
     target:self
     action:@selector(addWordAction:)];

    if(self.enableTodoMode){
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
            NSLocalizedString(@"Todo", @"待背"),
            NSLocalizedString(@"All", @"全部"),
        ]];

        self.listSegmentedControl = segmentedControl;

        [segmentedControl addEventHandler:^(UISegmentedControl * sender) {
            if(sender.selectedSegmentIndex == 0){
                weakSelf.model = RunningModelTodo;
            }
            else{
                weakSelf.model = RunningModelAll;
            }
        } forControlEvents:UIControlEventValueChanged];

        segmentedControl.selectedSegmentIndex = 0;
        self.navigationItem.titleView = segmentedControl;
    }

    self.modelChangeBind = binding(self, @"model", ^(NSObject *value){
        NSLog(@"Binding called");
        RunningModel model = (RunningModel)[(NSNumber *)value integerValue];
        if(model == RunningModelTodo){
            [weakSelf switchToWordList:YES];

            void (^showActivityBlock)()=^{
                    UIActionSheet *actionSheet = [UIActionSheet.alloc
                        initWithTitle:NSLocalizedString(@"addWordFromList", @"从词库添加单词")
                             delegate:weakSelf
                    cancelButtonTitle:NSLocalizedString(@"giveup", @"放弃")
               destructiveButtonTitle:nil
                    otherButtonTitles:NSLocalizedString(@"next", @"顺序"), NSLocalizedString(@"random", @"随机"), nil];
                    [actionSheet showFromToolbar:weakSelf.navigationController.toolbar];
            };

            UIBarButtonItem *pickWordsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+25" style:UIBarButtonItemStylePlain handler:^(id sender) {
                showActivityBlock();
                return;
            }];

            [weakSelf setToolbarItems:@[
                [UIBarButtonItem flexibleSpaceItem],
                pickWordsButtonItem,
                [UIBarButtonItem flexibleSpaceItem],
            ] animated:YES];

            if(weakSelf.wordFetchedResultsController.fetchedObjects.count == 0){
                showActivityBlock();
            }
        }
        else if(model == RunningModelAll){
            [weakSelf switchToWordList:NO];


            BOOL needAddWord = [weakSelf.wordList.objectID isEqual:[SLSharedConfig sharedInstance].manualList.objectID];

            if(needAddWord){
                [weakSelf setToolbarItems:@[
                    [UIBarButtonItem flexibleSpaceItem],
                    newWordButtonItem,
                    [UIBarButtonItem flexibleSpaceItem],
                ] animated:YES];
            }
            else{
                [weakSelf setToolbarItems:@[]];
            }
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
    self.wordFetchedResultsController = nil;
    [self.wordListTableView reloadData];
    NSPredicate *predicate;
    NSString *cacheName;
    if(autoList){
        predicate = [NSPredicate predicateWithFormat:@"(ignore = NULL OR ignore = NO) AND lists CONTAINS %@", self.wordList.todoList];
        cacheName = [NSString stringWithFormat:@"cache_%@", self.wordList.todoList.name];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"(ignore = NULL OR ignore = NO) AND lists CONTAINS %@", self.wordList];
        cacheName = [NSString stringWithFormat:@"cache_all_%@", self.wordList.name];
    }

    NSFetchRequest *fetchRequest = [Word MR_requestAllSortedBy:@"source,sortOrder,added" ascending:YES withPredicate:predicate];
    [fetchRequest setFetchBatchSize:40];
    self.wordFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread] sectionNameKeyPath:nil cacheName:cacheName];
    self.wordFetchedResultsController.delegate = self;
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
    wordRecord.source = @"Manual";
    [[SLSharedConfig sharedInstance].manualList addWordsObject:wordRecord];

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
    NSString *todoTitle = [NSString stringWithFormat:NSLocalizedString(@"todo (%d)", @"todo (%d)"), self.wordList.todoList.words.count];

    [self.listSegmentedControl setTitle:todoTitle forSegmentAtIndex:0];

    NSString* allTitle = [NSString stringWithFormat:NSLocalizedString(@"all (%d)", @"all (%d)"), self.wordList.words.count];
    [self.listSegmentedControl setTitle:allTitle forSegmentAtIndex:1];

    if(self.model == RunningModelAll){
        self.title = allTitle;
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
    return self.wordFetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WordTableViewCell *cell = (WordTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
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
        BOOL addOneIntoDownloadList = NO;
        if(self.model == RunningModelAll){
            word.ignore = @(YES);
            addOneIntoDownloadList = YES;
        }
        else{
            if(word.checkNumber.integerValue == 0){
                addOneIntoDownloadList = YES;
            }

            [word checkItNow];
            [self.wordList.todoList removeWordsObject:word];
        }

        [word removeListsObject:[SLSharedConfig sharedInstance].needsPostList];

        if(addOneIntoDownloadList){
            NSPredicate *predicate = [NSPredicate
                predicateWithFormat:@"postNumber == 0 AND (lists.name CONTAINS %@) AND (NOT %@ in lists.name) AND (NOT %@ IN lists.name )",
                    self.wordList.name,
                    [SLSharedConfig sharedInstance].noPostDownloadedList.name,
                    [SLSharedConfig sharedInstance].needsPostList.name
            ];
            Word *wordNeedPost = [Word MR_findFirstWithPredicate:predicate sortedBy:@"sortOrder" ascending:YES];
            if(wordNeedPost != nil){
                [[SLSharedConfig sharedInstance].needsPostList addWordsObject:wordNeedPost];
            }
        }

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.model == RunningModelAll){
        return NSLocalizedString(@"Ignore", @"Ignore");
    }
    else if(self.model == RunningModelTodo) {
        return NSLocalizedString(@"Remembered", @"Remembered");
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
        default:
            return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(ignore = NULL OR ignore = FALSE) AND checkNumber = 0 AND (lists CONTAINS %@)", self.wordList];

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

        [self.wordList.todoList addWords:mutableSet];
        [[SLSharedConfig sharedInstance].needsPostList addWords:mutableSet];
        [[SLSharedConfig sharedInstance].postDownloader fire];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}
@end