//
//  ViewController.m
//  7times
//
//  Created by Li Shuo on 13-9-10.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "ViewController.h"
#import "MWFeedParser.h"
#import "FVDeclaration.h"
#import "FVDeclareHelper.h"
#import "A2DynamicDelegate.h"
#import "NSObject+AssociatedObjects.h"
#import "TTTTimeIntervalFormatter.h"
#import "RXMLElement.h"
#import "UIControl+BlocksKit.h"
#import "Post.h"
#import "Word.h"
#import "Check.h"
#import "NSSet+BlocksKit.h"
#import "DotView.h"
#import "NSTimer+BlocksKit.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MWFeedParser *feedParser;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UITableView *itemListTableView;
@property (nonatomic, strong) UITableView *wordListTableView;
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) UITextField *inputField;

@property (nonatomic, strong) NSFetchedResultsController *wordFetchedResultsController;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _wordFetchedResultsController = [Word MR_fetchAllSortedBy:@"added" ascending:NO withPredicate:nil groupBy:nil delegate:self];

    self.items = [NSMutableArray array];

    typeof(self) __weak weakSelf = self;

    self.declaration = [dec(@"root") $:@[
        [dec(@"sidebar", CGRectMake(0, 0, 200, FVP(1)), ^{
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
                    return weakSelf.wordFetchedResultsController.sections.count;
                }];

                [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tv, NSInteger section){
                    return [weakSelf.wordFetchedResultsController.sections[section] numberOfObjects];
                }];

                tableView.rowHeight = 48;

                [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath *indexPath){
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
                                dec(@"word", CGRectMake(10, FVCenter, 120, 25), ^{
                                    UITextView *label = [[UITextView alloc] init];
                                    label.tag = 101;
                                    label.font = [UIFont boldSystemFontOfSize:18];
                                    label.textColor = [UIColor blackColor];
                                    label.backgroundColor = [UIColor clearColor];
                                    label.editable = NO;
                                    label.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
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
        dec(@"Item list", CGRectMake(FVAfter, 0, FVTillEnd, FVP(1)), ^{
            UITableView *tableView = [[UITableView alloc] init];
            A2DynamicDelegate *dataSource = tableView.dynamicDataSource;
            [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tableView, NSInteger section){
                return weakSelf.items.count;
            }];

            static char key;
            static char postKey;

            tableView.rowHeight = 160;

            [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tableView, NSIndexPath *indexPath){
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
                if(cell==nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                    UITableViewCell * __weak weakCell = cell;
                    UITableView *__weak weakTableView = tableView;

                    FVDeclaration *declaration = [dec(@"cell", CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight)) $:@[
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
                            [dec(@"wordbutton", CGRectMake(FVT(160), 5, 140, 20), ^{
                                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

                                [button setTitle:@"word" forState:UIControlStateNormal];
                                button.layer.cornerRadius = 5.f;
                                button.backgroundColor = [UIColor colorWithRed:192/255.f green:57/255.f blue:43/255.f alpha:1.f];
                                button.titleLabel.font = [UIFont systemFontOfSize:15];

                                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                                [button addEventHandler:^(UIButton *btn) {
                                    NSIndexPath* indexPath = [weakTableView indexPathForCell:weakCell];
                                    Post *p = (Post*) [cell associatedValueForKey:&postKey];

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

                                    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

                                    [weakSelf.items removeObject:p];
                                    [weakSelf.itemListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                } forControlEvents:UIControlEventTouchUpInside];

                                button.tag = 106;
                                return button;
                            }()) postProcess:^(FVDeclaration *d) {
                                UIButton* btn = (UIButton *) d.object;
                                CGRect frame = btn.frame;
                                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
                                [btn sizeToFit];
                                btn.frame = CGRectMake(frame.size.width + frame.origin.x - btn.frame.size.width, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
                            }],
                            ]],
                        [dec(@"titleContainer", CGRectMake(10, FVA(0), FVFill, FVTillEnd), ^{
                            UIView *view = [[UIView alloc] init];
                            view.backgroundColor = [UIColor colorWithRed:236/255.f green:240/255.f blue:241/255.f alpha:1.f];
                            return view;
                        }()) $:@[
                            dec(@"title", CGRectMake(10, 5, FVT(5), 25), ^{
                                UITextView *label = [[UITextView alloc] init];
                                label.tag = 101;
                                label.backgroundColor = [UIColor clearColor];
                                label.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
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
                Post *post = weakSelf.items[indexPath.row];
                [cell associateValue:post withKey:&postKey];
                UILabel *label = [cell viewWithTag:101];
                label.text = post.title;

                UILabel *datetime = [cell viewWithTag:102];
                TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
                datetime.text = [formatter stringForTimeInterval:[post.date timeIntervalSinceNow]];

                UILabel *source = (UILabel *)[cell viewWithTag:104];
                source.text = post.source;

                UITextView *textView = (UITextView *)[cell viewWithTag:105];
                textView.text = post.summary;

                UIButton *wordButton = (UIButton *)[cell viewWithTag:106];
                [wordButton setTitle:[post.word.anyObject word] forState:UIControlStateNormal];

                FVDeclaration *declaration = (FVDeclaration *) [cell associatedValueForKey:&key];
                declaration.unExpandedFrame = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
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

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Add word" action:@selector(addWordMenuAction:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    menuCont.menuItems = @[menuItem];

    _timer = [NSTimer timerWithTimeInterval:3 block:^(NSTimeInterval time) {
        [self loadPost];
    } repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(void)dealloc{
    [_timer invalidate];
}

-(void)addWord:(NSString*)word{
    word = [word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];

    Word *wordRecord;

    wordRecord = [Word MR_findFirstByAttribute:@"word" withValue:word inContext:localContext];
    if(wordRecord){
        NSLog(@"Word already there, no need to create a new one");
        return;
    }

    wordRecord = [Word MR_createInContext:localContext];

    wordRecord.word = word;
    wordRecord.added = [NSDate date];

    [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [self.wordListTableView reloadData];
        self.inputField.text = nil;

        //Trigger the load post
        [self loadPostForWord:wordRecord];
    }];
}


-(UIView*)firstResponder:(UIView*)view{
    if([view isFirstResponder]){
        return view;
    }

    for(UIView *childView in view.subviews){
        UIView *v = [self firstResponder:childView];
        if(v){
            return v;
        }
    }

    return nil;
}

-(void)addWordMenuAction:(id)sender{
    UIView *firstResponder = [self firstResponder:self.view];
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

BOOL pureTextFont(RXMLElement* element){
    if([element children:@"font"].count > 0){
        return NO;
    }
    if([element.tag isEqualToString:@"font"]){
        BOOL __block notPureText = NO;
        [element iterate:@"*" usingBlock:^(RXMLElement *element) {
            if(!pureTextFont(element)){ notPureText = YES; }
        }];

        if(notPureText){return NO;}
    }

    return YES;
}

-(void)loadPost{
    NSArray* array = [Word MR_findAll];
    for(Word *word in array){
        if(word.check.count < 7){
            NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:0];
            for(Check *check in word.check){
                if ([lastTime compare:check.date] == NSOrderedAscending){
                    lastTime = check.date;
                }
            }

            if([[NSDate date] timeIntervalSinceDate:lastTime] > 60 * 60){
                // If longer than 1 hour, load the post
                [self loadPostForWord:word];
            }
        }
    }
}

-(void)loadPostForWord:(Word *)word{
    if(word.post.count == 0){
        NSURL *feedURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://news.google.com/news?q=%@&output=rss", word.word]];
        self.feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];

        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeAsynchronously;

        A2DynamicDelegate *delegate = [_feedParser dynamicDelegateForProtocol:@protocol(MWFeedParserDelegate)];
        typeof(self) __weak weakSelf = self;
        [delegate implementMethod:@selector(feedParser:didParseFeedItem:) withBlock:^(MWFeedParser *fp, MWFeedItem* item){
            dispatch_async(dispatch_get_main_queue(), ^{
                RXMLElement *doc = [[RXMLElement alloc] initFromXMLData:[item.summary dataUsingEncoding:NSUTF8StringEncoding]];

                NSString *title = item.title;
                NSString *__block source;
                NSString *__block summary;

                [doc iterateWithRootXPath:@"//font" usingBlock:^(RXMLElement *element) {
                    if(pureTextFont(element)){
                        NSString *value = element.text;
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if(value.length > 0){
                            if(source == nil){
                                source = value;
                            }
                            else{
                                if(![source isEqualToString:value]){
                                    if(summary == nil){
                                        summary = value;
                                    }
                                }
                            }
                        }
                    }
                }];

                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];

                Post *post = [Post MR_findFirstByAttribute:@"id" withValue:item.identifier];
                if(post != nil){
                    NSLog(@"Post already in, skip this");
                    return;
                }

                post = [Post MR_createInContext:localContext];
                post.id = item.identifier;
                post.title = title;
                post.source = source;
                post.summary = summary;
                post.date = item.date;
                post.url = item.link;

                [post addWordObject:word];

                [localContext MR_saveToPersistentStoreAndWait];
            });
        }];

        [delegate implementMethod:@selector(feedParserDidFinish:) withBlock:^(MWFeedParser *fp){
            [weakSelf loadPostForWord:word];
        }];
        _feedParser.delegate = (id)delegate;

        [_feedParser parse];
    }
    else{
        int added = 0;
        for(Post *p in word.post){
            if(p.check == nil){
                if(![self.items containsObject:p]){
                    [self.items addObject:p];
                    [self.itemListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.items.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    added++;

                    if(added >= 2){
                        break;
                    }
                }
            }
        }
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"Change detected:%@", anObject);
    if([controller isEqual:self.wordFetchedResultsController]){
        //Scroll to the editing word
        NSIndexPath* scrollTo = indexPath;
        if(!scrollTo){
            scrollTo = newIndexPath;
        }
        [self.wordListTableView scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionTop animated:YES];

        switch (type){
            case NSFetchedResultsChangeInsert:
                [self.wordListTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.wordListTableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [self.wordListTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            case NSFetchedResultsChangeDelete:
                [self.wordListTableView deleteRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }
}

@end
