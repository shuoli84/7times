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

@interface IPhoneViewController() <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;
@end

@implementation IPhoneViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor greenSeaColor];
        self.navigationController.navigationBar.translucent = NO;
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor greenSeaColor];
    }

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    typeof(self) __weak weakSelf = self;

    self.wordFetchedResultsController = [Word MR_fetchAllSortedBy:@"lastCheckTime" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    [self.wordFetchedResultsController.fetchRequest setSortDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"lastCheckTime" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"source" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES],
    ]];
    [self.wordFetchedResultsController performFetch:nil];

    self.declaration = [dec(@"root", CGRectZero) $:@[
        [dec(@"wordView", CGRectMake(0, 0, FVP(1), FVP(1))) $:@[
            dec(@"wordList", CGRectMake(0, FVA(0), FVP(1), FVFill), ^{
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                self.wordListTableView = tableView;

                tableView.backgroundColor = [UIColor whiteColor];
                tableView.rowHeight = 48;
                tableView.allowsSelection = YES;

                [weakSelf setTableDelegateForWordTable:tableView];

                A2DynamicDelegate *dataSource = tableView.dynamicDataSource;

                [dataSource implementMethod:@selector(numberOfSectionsInTableView:) withBlock:^NSInteger(UITableView *tv){
                    return (NSInteger)weakSelf.wordFetchedResultsController.sections.count;
                }];

                [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView* tv, NSInteger section){
                    return [weakSelf.wordFetchedResultsController.sections[(NSUInteger)section] numberOfObjects];
                }];

                [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath* indexPath){
                    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
                    static char key;

                    if(cell == nil){
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

                        FVDeclaration *declaration = [dec(@"cell", CGRectMake(0, 0, tv.bounds.size.width, 48)) $:@[
                            [dec(@"content", CGRectMake(0, 0, FVP(1.f), FVP(1.f)), ^{
                                UIView *view = [[UIView alloc] init];
                                view.backgroundColor =[UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                                view.clipsToBounds = YES;
                                return view;
                            }()) $:@[
                                dec(@"word", CGRectMake(10, FVCenter, FVT(80), 30), ^{
                                    UILabel *label = [[UILabel alloc] init];
                                    label.tag = 101;
                                    label.font = [UIFont boldSystemFontOfSize:18];
                                    label.textColor = [UIColor blackColor];
                                    label.backgroundColor = [UIColor clearColor];

                                    return label;
                                }()),
                                dec(@"dotView", CGRectMake(FVT(80), FVCenter, 75, 25), ^{
                                    DotView *dotView = [[DotView alloc]init];
                                    dotView.backgroundColor = [UIColor clearColor];
                                    dotView.leftMargin = 1.f;
                                    dotView.dotRadius = 3.f;
                                    dotView.spaceBetween = 3.f;
                                    dotView.tag = 102;
                                    return dotView;
                                }()),
                            ]]
                        ]];

                        [declaration setupViewTreeInto:cell];
                        [declaration updateViewFrame];
                        [cell associateValue:declaration withKey:&key];
                    }

                    UITextView *label = (UITextView *)[cell viewWithTag:101];

                    Word *word = [weakSelf.wordFetchedResultsController objectAtIndexPath:indexPath];
                    label.text = word.word;

                    DotView *dotView = (DotView*)[cell viewWithTag:102];
                    dotView.dotNumber = word.checkNumber.integerValue;
                    [dotView setNeedsDisplay];
                    return cell;
                }];

                tableView.dataSource = (id)dataSource;
                return tableView;
            }()),
        ]],
    ]];


    [self.declaration setupViewTreeInto:self.view];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];
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

-(void)setTableDelegateForWordTable:(UITableView *)wordTable{
    A2DynamicDelegate *delegate = wordTable.dynamicDelegate;

    typeof(self) __weak weakSelf = self;
    [delegate implementMethod:@selector(tableView:didSelectRowAtIndexPath:) withBlock:^(UITableView *tableView, NSIndexPath* indexPath){
        Word* word = [weakSelf.wordFetchedResultsController objectAtIndexPath:indexPath];
        WordDetailViewController *wordDetailViewController = [[WordDetailViewController alloc] init];
        wordDetailViewController.word = word;
        [weakSelf.navigationController pushViewController:wordDetailViewController animated:YES];
    }];

    wordTable.delegate = (id)delegate;
}

- (IBAction)addWordAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewWord_Title", @"New Word") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Add", @"Add"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

@end