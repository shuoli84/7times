//
// Created by Li Shuo on 13-10-12.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import "WordListViewController.h"
#import "UIControl+BlocksKit.h"
#import "WordListManager.h"
#import "WordList.h"
#import "NSObject+AssociatedObjects.h"
#import "Word.h"
#import "MagicalRecordShorthand.h"

@interface WordListViewController()
@property (nonatomic, strong) FVDeclaration *viewDeclare;
@property (nonatomic, strong) WordListManager *wordListManager;
@end

@implementation WordListViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.wordListManager = [[WordListManager alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];

    typeof(self) __weak weakSelf = self;
    self.viewDeclare = [dec(@"root") $:@[
        dec(@"wordListTableView", CGRectMake(0, 0, FVP(1), FVT(50)), ^{
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.allowsSelection = NO;
            tableView.dataSource = [weakSelf dataSourceForTableView:tableView];
            return tableView;
        }()),
        [dec(@"leftContainer", CGRectMake(0, FVT(50), FVP(0.5), 50)) $:@[
            dec(@"backButton", CGRectMake(0, 0, FVT(1), FVP(1.f)), ^{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
                [button setTitle:@"back" forState:UIControlStateNormal];

                button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                [button addEventHandler:^(id sender) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                } forControlEvents:UIControlEventTouchUpInside];
                return button;
            }()),
        ]],
        [dec(@"rightContainer", CGRectMake(FVA(0), FVT(50), FVP(0.5), 50)) $:@[
            dec(@"recoverButton", CGRectMake(1, FVT(50), FVTillEnd, 50), ^{
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
                [button setTitle:@"recover" forState:UIControlStateNormal];

                button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                [button addEventHandler:^(id sender) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                } forControlEvents:UIControlEventTouchUpInside];
                return button;
            }()),
        ]],
    ]];

    [self.viewDeclare setupViewTreeInto:self.view];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.viewDeclare resetLayout];
    self.viewDeclare.unExpandedFrame = self.view.bounds;
    [self.viewDeclare updateViewFrame];
}

-(id<UITableViewDataSource>)dataSourceForTableView:(UITableView*)tableView{
    A2DynamicDelegate *dataSource = tableView.dynamicDataSource;

    typeof(self) __weak weakSelf = self;
    [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^int(UITableView *tv, int section){
        return weakSelf.wordListManager.allWordLists.count;
    }];

    [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^(UITableView *tv, NSIndexPath *indexPath){
        UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
        static char declarationKey;

        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

            typeof(cell) __weak weakCell = cell;
            typeof(tv) __weak weakTV = tv;
            FVDeclaration *declaration = [dec(@"cell") $:@[
                dec(@"title", CGRectMake(10, FVCenter, FVT(55), 30), ^{
                    UILabel *label = [[UILabel alloc] init];
                    label.tag = 101;
                    label.font = [UIFont boldSystemFontOfSize:19.f];
                    label.textColor = [UIColor blackColor];
                    label.backgroundColor = [UIColor whiteColor];
                    return label;
                }()),
                dec(@"button", CGRectMake(FVT(55), FVCenter, 50, 30), ^{
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

                    button.titleLabel.font = [UIFont systemFontOfSize:15];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    button.backgroundColor = [UIColor colorWithRed:231.f/255.f green:76/255.f blue:60/255.f alpha:1.f];
                    button.layer.cornerRadius = 5.f;
                    button.tag = 102;

                    [button addEventHandler:^(id sender) {
                        NSIndexPath* idx = [weakTV indexPathForCell:weakCell];
                        WordList* wordList = [weakSelf.wordListManager.allWordLists objectAtIndex:(uint)idx.row];

                        NSLog(@"Start loading wordlist: %@", wordList.name);

                        //dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray* words = wordList.words;
                            for(NSString *word in words){
                                BOOL alreadyIn = [Word MR_findByAttribute:@"word" withValue:word].count != 0;
                                if(!alreadyIn){
                                    NSLog(@"create word: %@", word);
                                    Word *wordEntity = [Word MR_createEntity];
                                    wordEntity.word = word;
                                    wordEntity.added = [NSDate date];

                                    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
                                }
                            }
                        //});

                    } forControlEvents:UIControlEventTouchUpInside];
                    return button;
                }()),
            ]];

            [declaration setupViewTreeInto:cell];
            [cell associateValue:declaration withKey:&declarationKey];
        }

        WordList *wordList = [weakSelf.wordListManager.allWordLists objectAtIndex:(uint)indexPath.row];
        cell.textLabel.text = wordList.name;

        UILabel *title = (UILabel *)[cell viewWithTag:101];
        title.text = wordList.name;

        UIButton *button = (UIButton *)[cell viewWithTag:102];
        [button setTitle:@"load" forState:UIControlStateNormal];

        FVDeclaration *declaration = [cell associatedValueForKey:&declarationKey];
        declaration.unExpandedFrame = CGRectMake(0, 0, tv.bounds.size.width, tv.rowHeight);
        [declaration updateViewFrame];
        return cell;
    }];

    return (id)dataSource;
}
@end