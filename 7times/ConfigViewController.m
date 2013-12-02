//
// Created by Li Shuo on 13-12-2.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclaration.h>
#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
#import "ConfigViewController.h"
#import "UIView+BlocksKit.h"


@interface ConfigViewController() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FVDeclaration *declaration;

@property (nonatomic, strong) NSArray *configurations;
@end

@implementation ConfigViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];

    typeof(self) __weak weakSelf = self;
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];

    navigationItem.leftBarButtonItem = backButtonItem;
    [navigationBar pushNavigationItem:navigationItem animated:NO];

    self.declaration = [dec(@"root") $:@[
        dec(@"toolbar", CGRectMake(0, 0, FVP(1.f), 44), navigationBar),
        dec(@"tableview", CGRectMake(0, FVA(0), FVP(1.f), FVTillEnd), ^{
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

            tableView.dataSource = self;
            tableView.delegate = self;

            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

            return tableView;
        }())
    ]];

    [self.declaration setupViewTreeInto:self.view];

    self.configurations = @[
        @[@"Network", @[
            @[@"Auto download news under wifi", @"switch", @1],
        ]]
    ];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration updateViewFrame];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.configurations.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.configurations[section][1];
    return items.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.configurations[section][0];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSArray *item = self.configurations[indexPath.section][1][indexPath.row];

    NSString *name = item[0];
    NSString *type = item[1];
    NSString *tag = item[2];

    cell.textLabel.text = name;
    [cell.contentView eachSubview:^(UIView *view) {
        [view removeFromSuperview];
    }];

    if([type isEqualToString:@"switch"]){
        UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(300, 0, 100, 44)];
        [cell.contentView addSubview:uiSwitch];
    }

    return cell;
}


@end