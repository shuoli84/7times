//
//  ViewController.m
//  7times
//
//  Created by Li Shuo on 13-9-10.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "IPadViewController.h"
#import "FVDeclaration.h"
#import "FVDeclareHelper.h"
#import "A2DynamicDelegate.h"
#import "NSObject+AssociatedObjects.h"
#import "TTTTimeIntervalFormatter.h"
#import "UIControl+BlocksKit.h"
#import "Post.h"
#import "Word.h"
#import "Check.h"
#import "NSSet+BlocksKit.h"
#import "DotView.h"
#import "SLSharedConfig.h"
#import "PostManager.h"
#import "UIView+FindFirstResponder.h"

@interface IPadViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) PostManager *postManager;
@property (nonatomic, strong) UITableView *itemListTableView;
@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITextField *inputField;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;
@end

@implementation IPadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    BOOL ios7 = 7 <= [[versionCompatibility objectAtIndex:0] intValue];

    self.postManager = [[PostManager alloc] init];

    _wordFetchedResultsController = [Word MR_fetchAllSortedBy:@"added" ascending:NO withPredicate:nil groupBy:nil delegate:self];

    typeof(self) __weak weakSelf = self;
    [SLSharedConfig sharedInstance].coreDataReady = ^{
        [weakSelf.wordFetchedResultsController performFetch:nil];
        [weakSelf.wordListTableView reloadData];
    };

    self.declaration = [dec(@"root") $:@[
        [dec(@"sidebar", CGRectMake(0, 0, 200, FVTillEnd), ^{
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
            return view;
        }()) $:@[
            [dec(@"add word", CGRectMake(5, 5, FVT(10), 40)) $:@[
                dec(@"inputField", CGRectMake(0, 0, FVT(45), FVP(1)), ^{
                    UITextField *field = [[UITextField alloc] init];
                    field.placeholder = @"input here";
                    field.backgroundColor = [UIColor whiteColor];
                    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
                    field.leftViewMode = UITextFieldViewModeAlways;
                    field.autocapitalizationType = UITextAutocapitalizationTypeNone;

                    weakSelf.inputField = field;
                    return field;
                }()),
                dec(@"addButton", CGRectMake(FVA(5), 0, 40, FVP(1)), ^{
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.titleLabel.font = [UIFont systemFontOfSize:34];
                    [button setTitle:@"+" forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.layer.cornerRadius = 5.f;
                    button.backgroundColor = [UIColor whiteColor];

                    [button addEventHandler:^(UIButton* bt) {
                        [weakSelf addWord:weakSelf.inputField.text];

                    } forControlEvents:UIControlEventTouchUpInside];

                    return button;
                }())
            ]],
            dec(@"title", CGRectMake(0, FVA(5), FVP(1), 20), ^{
                UILabel *label = [[UILabel alloc]init];
                label.text = @"Word List";
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:18];
                return label;
            }()),
            dec(@"word list", CGRectMake(0, FVA(0), FVP(1), FVTillEnd), ^{
                UITableView *tableView = [[UITableView alloc] init];
                A2DynamicDelegate *dataSource = tableView.dynamicDataSource;

                [dataSource implementMethod:@selector(numberOfSectionsInTableView:) withBlock:^NSInteger(UITableView *tv){
                    return (NSInteger)weakSelf.wordFetchedResultsController.sections.count;
                }];

                [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tv, NSInteger section){
                    return [weakSelf.wordFetchedResultsController.sections[(NSUInteger)section] numberOfObjects];
                }];

                tableView.rowHeight = 48;

                [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath *indexPath){
                    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
                    static char key;

                    if(cell == nil){
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                        cell.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];

                        FVDeclaration *declaration = [dec(@"cell", CGRectMake(0, 0, tv.bounds.size.width, 48)) $:@[
                            [dec(@"content", CGRectMake(5, 5, FVT(10), FVTillEnd), ^{
                                UIView *view = [[UIView alloc] init];
                                view.backgroundColor =[UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                                view.clipsToBounds = YES;
                                return view;
                            }()) $:@[
                                dec(@"word", CGRectMake(10, FVCenter, 120, 30), ^{
                                    UITextView *label = [[UITextView alloc] init];
                                    label.tag = 101;
                                    label.font = [UIFont boldSystemFontOfSize:18];
                                    label.textColor = [UIColor blackColor];
                                    label.backgroundColor = [UIColor clearColor];
                                    label.editable = NO;

                                    if (ios7) {
                                        label.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
                                    } else { /// iOS4 is installed
                                        label.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
                                    }
                                    label.scrollEnabled = NO;
                                    return label;
                                }()),
                                dec(@"dotView", CGRectMake(FVT(70), FVCenter, 60, 25), ^{
                                    DotView *dotView = [[DotView alloc]init];
                                    dotView.backgroundColor = [UIColor clearColor];
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
                    dotView.dotNumber = word.check.count;
                    [dotView setNeedsDisplay];
                    return cell;
                }];
                tableView.dataSource = (id)dataSource;
                tableView.allowsSelection = NO;

                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                tableView.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];

                weakSelf.wordListTableView = tableView;
                return tableView;
            }()),
        ]],
        dec(@"Item list", CGRectMake(FVAfter, FVSameAsPrev, FVTillEnd, FVTillEnd), ^{
            UITableView *tableView = [[UITableView alloc] init];
            A2DynamicDelegate *dataSource = tableView.dynamicDataSource;
            [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tv, NSInteger section){
                return weakSelf.postManager.posts.count;
            }];

            static char key;
            static char postKey;

            tableView.rowHeight = 160;

            [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath *indexPath){
                UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
                if(cell==nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                    UITableViewCell * __weak weakCell = cell;
                    UITableView *__weak weakTableView = tv;

                    FVDeclaration *declaration = [dec(@"cell", CGRectMake(0, 0, tv.bounds.size.width, tv.rowHeight)) $:@[
                        [dec(@"topping", CGRectMake(10, 0, FVP(1), 30)) $:@[
                            dec(@"source", CGRectMake(0, FVCenter, 120, 20), ^{
                                UILabel *label = [[UILabel alloc] init];
                                label.text = @"Google News";
                                label.tag = 104;
                                label.textColor = [UIColor colorWithRed:1.f green:128/255.f blue:0.f alpha:1.f];
                                label.font = [UIFont boldSystemFontOfSize:15];
                                label.backgroundColor = [UIColor clearColor];
                                return label;
                            }()),
                            dec(@"datetime", CGRectMake(FVA(10), FVSameAsPrev, 100, FVSameAsPrev), ^{
                                    UILabel *label = [[UILabel alloc] init];

                                    label.tag = 102;
                                    label.backgroundColor = [UIColor clearColor];
                                    label.font = [UIFont boldSystemFontOfSize:15];
                                    label.textColor = [UIColor colorWithRed:127/255.f green:140/255.f blue:141/255.f alpha:1.f];
                                    return label;
                            }()),
                            [dec(@"wordbutton", CGRectMake(FVT(160), 5, 140, 30), ^{
                                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

                                [button setTitle:@"word" forState:UIControlStateNormal];
                                button.layer.cornerRadius = 5.f;
                                button.backgroundColor = [UIColor colorWithRed:192/255.f green:57/255.f blue:43/255.f alpha:1.f];
                                button.titleLabel.font = [UIFont systemFontOfSize:15];

                                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                                [button addEventHandler:^(UIButton *btn) {
                                    NSIndexPath*idxPth = [weakTableView indexPathForCell:weakCell];
                                    if(idxPth != nil){
                                        Post *p = (Post*) [weakCell associatedValueForKey:&postKey];

                                        Check *check = [Check MR_createEntity];
                                        check.date = [NSDate date];
                                        [p setCheck:check];

                                        [p.word each:^(Word *w) {
                                            //Only set the check only last check is at least 30 minutes ago
                                            NSDate* lastCheck = [NSDate dateWithTimeIntervalSince1970:0];
                                            for(Check *c in w.check){
                                                if([lastCheck compare:c.date] == NSOrderedAscending){
                                                    lastCheck = c.date;
                                                }
                                            }

                                            if([[NSDate date] timeIntervalSinceDate:lastCheck] > 30 * 60){
                                                [w addCheck:[NSSet setWithObject:check]];
                                            }
                                            else{
                                                NSLog(@"The last check for word within 30 minutes, ignore the check");
                                            }
                                        }];

                                        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                                            NSLog(@"Check saved");
                                        }];

                                        [weakSelf.postManager.posts removeObject:p];
                                        [weakSelf.itemListTableView deleteRowsAtIndexPaths:@[idxPth] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    }
                                } forControlEvents:UIControlEventTouchUpInside];

                                button.tag = 106;
                                return button;
                            }()) postProcess:^(FVDeclaration *d) {
                                UIButton* btn = (UIButton *) d.object;
                                CGRect frame = btn.frame;
                                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
                                [btn sizeToFit];
                                btn.frame = CGRectMake(frame.size.width + frame.origin.x - btn.frame.size.width, frame.origin.y, btn.frame.size.width, frame.size.height);
                            }],
                            ]],
                        [dec(@"titleContainer", CGRectMake(10, FVA(0), FVFill, FVTillEnd), ^{
                            UIView *view = [[UIView alloc] init];
                            view.backgroundColor = [UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                            return view;
                        }()) $:@[
                            dec(@"title", CGRectMake(10, 0, FVT(5), 30), ^{
                                UITextView *label = [[UITextView alloc] init];
                                label.tag = 101;
                                label.backgroundColor = [UIColor clearColor];

                                if (ios7) {
                                    label.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                                } else { /// iOS4 is installed
                                    label.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
                                }
                                label.editable = NO;
                                label.font = [UIFont systemFontOfSize:18];
                                label.scrollEnabled = NO;
                                return label;
                            }()),
                            dec(@"summary", CGRectMake(20, FVA(0), FVT(5), FVTillEnd), ^{
                                UITextView *textView = [[UITextView alloc]init];
                                textView.tag = 105;
                                textView.editable = NO;
                                textView.font = [UIFont systemFontOfSize:16];
                                textView.backgroundColor = [UIColor clearColor];
                                return textView;
                            }()),
                        ]],

                        dec(@"space", CGRectMake(FVT(10), 0, 10, 0))
                    ]];

                    [declaration setupViewTreeInto:cell];

                    [cell associateValue:declaration withKey:&key];
                }
                Post *post = weakSelf.postManager.posts[(NSUInteger)indexPath.row];
                [cell associateValue:post withKey:&postKey];
                UILabel *label = (UILabel *)[cell viewWithTag:101];
                label.text = post.title;

                UILabel *datetime = (UILabel*)[cell viewWithTag:102];
                TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
                datetime.text = [formatter stringForTimeInterval:[post.date timeIntervalSinceNow]];

                UILabel *source = (UILabel *)[cell viewWithTag:104];
                source.text = post.source;

                UITextView *textView = (UITextView *)[cell viewWithTag:105];
                textView.text = post.summary;

                UIButton *wordButton = (UIButton *)[cell viewWithTag:106];
                [wordButton setTitle:[(Word*)post.word.anyObject word] forState:UIControlStateNormal];
                wordButton.backgroundColor = [[SLSharedConfig sharedInstance] colorForCount:[(Word *)post.word.anyObject check].count];

                FVDeclaration *declaration = (FVDeclaration *) [cell associatedValueForKey:&key];
                declaration.unExpandedFrame = CGRectMake(0, 0, tv.bounds.size.width, tv.rowHeight);
                [declaration resetLayout];
                [declaration updateViewFrame];

                return cell;
            }];

            tableView.dataSource = (id)dataSource;

            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            tableView.allowsSelection = NO;

            weakSelf.itemListTableView = tableView;
            return tableView;
        }()),
    ]];

    [self.declaration setupViewTreeInto:self.view];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];

    [self.postManager setPostChangeBlock:^(PostManager *postManager, Post *post, int index, int newIndex) {
        [weakSelf.itemListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

-(void)addWord:(NSString*)word{
    word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    Word *wordRecord;

    wordRecord = [Word MR_findFirstByAttribute:@"word" withValue:word];
    if(wordRecord){
        NSLog(@"Word already there, no need to create a new one");
        return;
    }

    wordRecord = [Word MR_createEntity];

    wordRecord.word = word;
    wordRecord.added = [NSDate date];

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [self.wordListTableView reloadData];
        self.inputField.text = nil;
        [self.postManager loadPostForWord:wordRecord];
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

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self.declaration resetLayout];
    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration updateViewFrame];

    [self.itemListTableView reloadRowsAtIndexPaths:[self.itemListTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"Change detected:%@", anObject);
    if([controller isEqual:self.wordFetchedResultsController]){

        switch (type){
            case NSFetchedResultsChangeInsert:
                [self.wordListTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.wordListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                break;
            case NSFetchedResultsChangeMove:
                [self.wordListTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            case NSFetchedResultsChangeDelete:
                [self.wordListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }

        //Scroll to the editing word
        NSIndexPath* scrollTo = indexPath;
        if(!scrollTo && newIndexPath){
            scrollTo = newIndexPath;
        }

        if(scrollTo){
            [self.wordListTableView scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

@end
