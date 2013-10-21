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
#import "SVProgressHUD.h"
#import "Flurry.h"
#import
 "StoreKit/StoreKit.h"
#import
 "SevenTimesIAPHelper.h"

@interface WordListViewController()
@property (nonatomic, strong) FVDeclaration *viewDeclare;
@property (nonatomic, strong) WordListManager *wordListManager;
@property (nonatomic, strong) NSArray *products;

@end

@implementation WordListViewController {
NSNumberFormatter * _priceFormatter;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.wordListManager = [[WordListManager alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];

self.refreshControl = [[UIRefreshControl alloc] init];
[self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];

self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

typeof(self) __weak weakSelf = self;
    self.viewDeclare = [dec(@"root") $:@[
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
[[SevenTimesIAPHelper sharedInstance] restoreCompletedTransactions];
} forControlEvents:UIControlEventTouchUpInside];
                return button;
            }()),
        ]],
    ]];

    [self.viewDeclare setupViewTreeInto:self.view];

[self reload];
[self.refreshControl beginRefreshing];

_priceFormatter = [[NSNumberFormatter alloc] init];
[_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
[_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.viewDeclare resetLayout];
    self.viewDeclare.unExpandedFrame = self.view.bounds;
    [self.viewDeclare updateViewFrame];
}

-(void)reload{
self.products = nil;
[self.tableView reloadData];
[[SevenTimesIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
if (success){
self.products = products;
[self.tableView reloadData];
}

[self.refreshControl endRefreshing];
}];
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
return self.products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
typeof(self) __weak weakSelf = self;
static char declarationKey;

if (cell == nil){
cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

typeof(cell) __weak weakCell = cell;
typeof(tableView) __weak weakTV = tableView;
FVDeclaration *declaration = [dec(@"cell") $:@[
dec(@"title", CGRectMake(10, FVCenter, FVT(55), 30), ^{
UILabel *label = [[UILabel alloc] init];
label.tag = 101;
label.font = [UIFont boldSystemFontOfSize:19.f];
label.textColor = [UIColor blackColor];
label.backgroundColor = [UIColor whiteColor];
return label;
}()),
dec(@"button", CGRectMake(FVT(90), FVCenter, 80, 30), ^{
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

button.titleLabel.font = [UIFont systemFontOfSize:15];
[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
button.backgroundColor = [UIColor colorWithRed:231.f/255.f green:76/255.f blue:60/255.f alpha:1.f];
button.layer.cornerRadius = 5.f;
button.tag = 102;

[button addEventHandler:^(id sender) {
NSIndexPath* idx = [weakTV indexPathForCell:weakCell];
SKProduct *product = weakSelf.products[(uint)idx.row];
if (![[SevenTimesIAPHelper sharedInstance] productPurchased:product.productIdentifier]){
NSLog(@"The product is not bought, buy it");
[Flurry logEvent:@"start_buy" withParameters:@{
@"name":product.localizedTitle
}];
[[SevenTimesIAPHelper sharedInstance] buyProduct:product];
return;
}

NSLog(@"The product already bought, load it");
WordList* wordList = [weakSelf.wordListManager.allWordLists objectForKey:product.productIdentifier];

NSLog(@"Start loading wordlist: %@", wordList.name);

NSArray* words = wordList.words;
NSString* source = wordList.name;

[Flurry logEvent:@"load_wordlist" withParameters:@{
@"name":wordList.name, @"count":@(words.count)
}];

int __block i = 0;
int count = words.count;

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
for (NSString *word in words){
i++;
BOOL alreadyIn = [Word MR_findFirstByAttribute:@"word" withValue:word] != nil;
if (!alreadyIn){
NSLog(@"create word: %@", word);
Word *wordEntity = [Word MR_createEntity];
wordEntity.word = word;
wordEntity.added = [NSDate date];
wordEntity.source = source;

[[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
}

if (i % 30 == 0){
dispatch_async(dispatch_get_main_queue(), ^{
[SVProgressHUD showProgress:(float)i/(float)count status:@"loading" maskType:SVProgressHUDMaskTypeGradient];
});
}

if (i >= count){
dispatch_async(dispatch_get_main_queue(), ^{
[SVProgressHUD dismiss];
});
}
}

if (self.finishLoadWordlist){
self.finishLoadWordlist();
}
});

} forControlEvents:UIControlEventTouchUpInside];
return button;
}()),
]];

[declaration setupViewTreeInto:cell];
[cell associateValue:declaration withKey:&declarationKey];
}

SKProduct *product = (SKProduct *)self.products[(uint)indexPath.row];

UILabel *title = (UILabel *)[cell viewWithTag:101];
title.text = product.localizedTitle;


[_priceFormatter setLocale:product.priceLocale];
NSString *priceTag = [_priceFormatter stringFromNumber:product.price];

UIButton *button = (UIButton *)[cell viewWithTag:102];
if ([[SevenTimesIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
[button setTitle:@"load" forState:UIControlStateNormal];
} else {
[button setTitle:priceTag forState:UIControlStateNormal];
}

FVDeclaration *declaration = [cell associatedValueForKey:&declarationKey];
declaration.unExpandedFrame = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
[declaration updateViewFrame];

return cell;
}

- (void)viewWillAppear:(BOOL)animated {
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {

NSString * productIdentifier = notification.object;
[_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
if ([product.productIdentifier isEqualToString:productIdentifier]) {
[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
*stop = YES;
}
}];

}
@end