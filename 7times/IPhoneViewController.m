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
#import "IPhoneViewController.h"
#import "Word.h"
#import "DotView.h"
#import "PostManager.h"
#import "Post.h"
#import "SLSharedConfig.h"
#import "Check.h"
#import "UIView+FindFirstResponder.h"
#import "Word+Util.h"
#import "Flurry.h"
#import "TSMiniWebBrowser.h"
#import "NSURL+QueryString.h"
#import "PostDownloader.h"
#import "WordListViewController.h"
#import "UIAlertView+BlocksKit.h"

@interface IPhoneViewController() <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) UITableView *itemListTableView;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;

@property (nonatomic, strong) PostManager *postManager;
@property (nonatomic, strong) PostDownloader *postDownloader;
@end

@implementation IPhoneViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    BOOL ios7 = 7 <= [[versionCompatibility objectAtIndex:0] intValue];

    typeof(self) __weak weakSelf = self;

    self.wordFetchedResultsController = [Word MR_fetchAllSortedBy:@"added" ascending:YES withPredicate:nil groupBy:nil delegate:self];

    [SLSharedConfig sharedInstance].coreDataReady = ^{
        [weakSelf.wordFetchedResultsController performFetch:nil];
        [weakSelf.wordListTableView reloadData];
    };

    self.postManager = [[PostManager alloc]init];
    self.postDownloader = [[PostDownloader alloc] init];

    self.declaration = [dec(@"root", CGRectZero, ^{
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView.contentSize = CGSizeMake(weakSelf.view.bounds.size.width * 2, weakSelf.view.bounds.size.height);
        return scrollView;
    }()) $:@[
        [dec(@"wordView", CGRectMake(0, 0, FVP(1), FVP(1))) $:@[
            dec(@"wordList", CGRectMake(0, FVA(0), FVP(1), FVFill), ^{
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                self.wordListTableView = tableView;

                tableView.backgroundColor = [UIColor whiteColor];
                tableView.rowHeight = 48;
                tableView.allowsSelection = NO;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

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
                            [dec(@"content", CGRectMake(5, 5, FVT(10), FVTillEnd), ^{
                                UIView *view = [[UIView alloc] init];
                                view.backgroundColor =[UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                                view.clipsToBounds = YES;
                                return view;
                            }()) $:@[
                                dec(@"word", CGRectMake(10, FVCenter, FVT(80), 30), ^{
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
            [dec(@"addButton", CGRectMake(0, FVT(50), FVP(.5), 50)) $:@[
                dec(@"button", CGRectMake(0, 0, FVT(1), FVP(1)), ^{
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

                    [button setTitle:@"+" forState:UIControlStateNormal];
                    button.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont boldSystemFontOfSize:22];

                    [button addEventHandler:^(id sender) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Word" message:nil delegate:weakSelf cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alertView show];
                    } forControlEvents:UIControlEventTouchUpInside];

                    return button;
                }())
            ]],
            [dec(@"loadButton", CGRectMake(FVA(0), FVT(50), FVP(.5), 50)) $:@[
                dec(@"button", CGRectMake(1, FVT(50), FVT(1), 50), ^{
                     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                     [button setTitle:@"load" forState:UIControlStateNormal];
                     button.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
                     button.titleLabel.font = [UIFont boldSystemFontOfSize:22];

                    [button addEventHandler:^(id sender) {
                        WordListViewController *wordListViewController = [[WordListViewController alloc] init];
                        wordListViewController.finishLoadWordlist = ^{
                            NSLog(@"word list load finished, fire the downloader");
                            [weakSelf.postDownloader fire];
                        };
                        [weakSelf presentViewController:wordListViewController animated:YES completion:nil];
                    } forControlEvents:UIControlEventTouchUpInside];
                    return button;
                }()),
            ]],

        ]],
        dec(@"itemView", CGRectMake(FVA(0), 0, FVP(1), FVT(0)), ^{
            UITableView *tableView = [[UITableView alloc] init];
            A2DynamicDelegate *dataSource = tableView.dynamicDataSource;
            [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tv, NSInteger section){
                return weakSelf.postManager.postCount;
            }];

            static char key;
            static char postKey;

            tableView.rowHeight = self.view.bounds.size.height;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.allowsSelection = NO;
            tableView.pagingEnabled = YES;

            [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath *indexPath){
                UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
                if(cell==nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                    UITableViewCell * __weak weakCell = cell;
                    UITableView *__weak weakTableView = tv;

                    FVDeclaration *declaration = [dec(@"cell", CGRectMake(0, 0, tv.bounds.size.width, tv.rowHeight)) $:@[
                        [dec(@"topping", CGRectMake(0, 0, FVP(1), 25)) $:@[
                            dec(@"source", CGRectMake(5, FVCenter, FVFill, 20), ^{
                                UILabel *label = [[UILabel alloc] init];
                                label.text = @"Google News";
                                label.tag = 104;
                                label.textColor = [UIColor colorWithRed:1.f green:128/255.f blue:0.f alpha:1.f];
                                label.font = [UIFont boldSystemFontOfSize:15];
                                label.backgroundColor = [UIColor clearColor];
                                return label;
                            }()),
                        ]],

                        [dec(@"container", CGRectMake(0, FVA(0), FVP(1.f), FVT(75)), ^{
                            UIView *view = [[UIView alloc] init];
                            view.backgroundColor = [UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                            return view;
                        }()) $:@[
                            dec(@"title", CGRectMake(0, FVA(5), FVT(5), 100), ^{
                                UITextView *label = [[UITextView alloc] init];
                                label.tag = 101;
                                label.backgroundColor = [UIColor clearColor];

                                label.editable = NO;
                                label.font = [UIFont systemFontOfSize:25];
                                label.scrollEnabled = NO;
                                return label;
                            }()),
                            dec(@"datetime", CGRectMake(5, FVA(5), FVP(1), 20), ^{
                                UILabel *label = [[UILabel alloc] init];

                                label.tag = 102;
                                label.backgroundColor = [UIColor clearColor];
                                label.font = [UIFont boldSystemFontOfSize:15];
                                label.textColor = [UIColor colorWithRed:127/255.f green:140/255.f blue:141/255.f alpha:1.f];
                                return label;
                            }()),
                            dec(@"summary", CGRectMake(5, FVA(0), FVT(5), FVTillEnd), ^{
                                UITextView *textView = [[UITextView alloc]init];
                                textView.tag = 105;
                                textView.editable = NO;
                                textView.font = [UIFont systemFontOfSize:20];
                                textView.backgroundColor = [UIColor clearColor];
                                return textView;
                            }()),

                        ]],
                        dec(@"doneButton", CGRectMake(0, FVT(50), FVT(104), 50), ^{
                            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                            button.layer.borderWidth = 3.f;
                            [button setTitle:@"Dismiss" forState:UIControlStateNormal];
                            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
                            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                            button.tag = 107;

                            [button addEventHandler:^(id sender) {
                                NSIndexPath*idx = [weakTableView indexPathForCell:weakCell];
                                if(idx != nil){
                                    Post *p = (Post*) [weakCell associatedValueForKey:&postKey];

                                    Check *check = [Check MR_createEntity];
                                    check.date = [NSDate date];
                                    [p setCheck:check];

                                    p.checked = [NSNumber numberWithBool:YES];

                                    Word *w = p.word;
                                    if([w lastCheckExpired]){
                                        [w addCheck:[NSSet setWithObject:check]];
                                        w.lastCheckTime = check.date;
                                        w.checkNumber = @(w.checkNumber.integerValue + 1);
                                    }
                                    else{
                                        NSLog(@"Not ready for a new check, ignore");
                                    }

                                    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

                                    [weakSelf.postManager removePostAtIndexPath:idx];
                                    [weakSelf.itemListTableView deleteRowsAtIndexPaths:@[idx] withRowAnimation:UITableViewRowAnimationFade];

                                    [Flurry logEvent:@"Post_dismiss" withParameters:@{
                                        @"word": [p.word word],
                                        @"post": p.title,
                                        @"post_url" : p.url,
                                    }];
                                }
                            } forControlEvents:UIControlEventTouchUpInside];

                            return button;
                        }()),
                        dec(@"lookupButton", CGRectMake(FVT(102), FVSameAsPrev, 50, FVTillEnd), ^{
                            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                            [button setTitle:@"?" forState:UIControlStateNormal];
                            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
                            button.tag = 108;

                            [button addEventHandler:^(id sender) {
                                NSIndexPath*idx = [weakTableView indexPathForCell:weakCell];
                                if(idx != nil){
                                    Post *p = (Post*) [weakCell associatedValueForKey:&postKey];
                                    Word *w = p.word;

                                    UIReferenceLibraryViewController *dictionViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:w.word];
                                    [weakSelf presentViewController:dictionViewController animated:YES   completion:nil];
                                }
                            } forControlEvents:UIControlEventTouchUpInside];
                            return button;
                        }()),
                        dec(@"openInBrowserButton", CGRectMake(FVT(50), FVSameAsPrev, 50, FVTillEnd), ^{
                            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                            [button setTitle:@">" forState:UIControlStateNormal];
                            button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
                            button.tag = 109;

                            [button addEventHandler:^(id sender) {
                                NSIndexPath *idx = [weakTableView indexPathForCell:weakCell];
                                if (idx != nil) {
                                    Post *p = (Post *) [weakCell associatedValueForKey:&postKey];
                                    NSURL *url = [NSURL URLWithString:p.url];
                                    if(url.dictionaryForQueryString[@"url"]){
                                        url = [NSURL URLWithString:url.dictionaryForQueryString[@"url"]];
                                        NSLog(@"Get real url:%@", url.absoluteString);
                                    }

                                    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", url.absoluteString]];

                                    TSMiniWebBrowser *browser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                                    browser.mode = TSMiniWebBrowserModeModal;
                                    [weakSelf presentViewController:browser animated:YES completion:nil];
                                }
                            } forControlEvents:UIControlEventTouchUpInside];
                            return button;
                        }()),
                    ]];

                    [declaration setupViewTreeInto:cell];

                    [cell associateValue:declaration withKey:&key];
                }
                Post *post = [weakSelf.postManager postForIndexPath:indexPath];
                [cell associateValue:post withKey:&postKey];

                Word *word = post.word;
                UIColor* wordColor;
                int checkNumber = word.checkNumber.integerValue;
                if(word.lastCheckExpired){
                    wordColor = [[SLSharedConfig sharedInstance] colorForCount:checkNumber];
                }
                else if(checkNumber >= 1){
                    wordColor = [[SLSharedConfig sharedInstance] colorForCount:checkNumber - 1];
                }
                else {
                    wordColor = [UIColor blackColor];
                }

                UIButton *dismissButton = (UIButton*)[cell viewWithTag:107];
                dismissButton.layer.borderColor = wordColor.CGColor;
                dismissButton.backgroundColor = wordColor;
                [dismissButton setTitle:word.word forState:UIControlStateNormal];

                UIButton *lookUpButton = (UIButton *) [cell viewWithTag:108];
                lookUpButton.backgroundColor = wordColor;

                UIButton *openLinkButton = (UIButton *) [cell viewWithTag:109];
                openLinkButton.backgroundColor = wordColor;

                UITextView *label = (UITextView *)[cell viewWithTag:101];
                label.text = post.title;

                FVDeclaration *declaration = (FVDeclaration *) [cell associatedValueForKey:&key];
                declaration.unExpandedFrame = CGRectMake(0, 0, tv.bounds.size.width, tv.rowHeight);
                [declaration resetLayout];
                [declaration updateViewFrame];

                [label sizeToFit];
                [declaration declarationByName:@"title"].unExpandedFrame = CGRectMake(0, FVA(5), FVT(5), label.frame.size.height);

                UILabel *datetime = (UILabel*)[cell viewWithTag:102];
                TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
                datetime.text = [formatter stringForTimeInterval:[post.date timeIntervalSinceNow]];

                UILabel *source = (UILabel *)[cell viewWithTag:104];
                source.text = post.source;

                UITextView *textView = (UITextView *)[cell viewWithTag:105];
                textView.text = post.summary;

                [declaration resetLayout];
                [declaration updateViewFrame];

                return cell;
            }];

            tableView.dataSource = (id)dataSource;

            weakSelf.itemListTableView = tableView;
            return tableView;
        }()),
    ]];

    [self.declaration setupViewTreeInto:self.view];

    [self.postManager setPostChangeBlock:^(PostManager *postManager, Post *post, int index, int newIndex) {
        [weakSelf.itemListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];

    [self.postManager startWithShouldBeginBlock:^BOOL {
        return YES;
    }];

    [self.postDownloader startWithShouldBeginBlock:^{
        return weakSelf.postManager.needNewPost;
    }                                oneWordFinish:^(NSString *word) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Word* wordRecord = [Word MR_findFirstByAttribute:@"word" withValue:word];
            [weakSelf.postManager loadPostForWord:wordRecord];
        });
    } completion:nil];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self.declaration resetLayout];
    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration updateViewFrame];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Add"]){
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
    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

    NSLog(@"Word saved");
    [self.postDownloader downloadForWord:word completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.postManager loadPostForWord:wordRecord];
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

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
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
    }
}
@end