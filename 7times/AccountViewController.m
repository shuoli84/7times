//
// Created by Li Shuo on 13-11-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "AccountViewController.h"
#import "UIColor+FlatUI.h"
#import "WeiboSDK.h"
#import "SLSharedConfig.h"
#import "Binding.h"
#import "WeiboUserInfo.h"
#import "UIImageView+WebCache.h"


@interface AccountViewController() <WBHttpRequestDelegate>

@property (nonatomic, strong) FVDeclaration *declaration;
@property (nonatomic, strong) Binding *weiboLoginBinding;
@property (nonatomic, strong) Binding *weiboUserBinding;

@property (nonatomic, strong) UIButton *loginToWeiboButton;
@property (nonatomic, strong) UIView *userPanelView;
@property (nonatomic, strong) UIImageView *profileImageView;

@end

@implementation AccountViewController {

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.declaration = [dec(@"root") $:@[
        dec(@"loginToWeibo", CGRectMake(FVCenter, FVCenter, FVP(0.6), 50), self.loginToWeiboButton = ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

            [button setTitle:@"登陆微博" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor greenSeaColor];

            return button;
        }()),
        [dec(@"weiboUser", CGRectMake(FVCenter, FVCenter, FVP(0.6), 150), self.userPanelView = [UIView new]) $:@[
            dec(@"userProfileImage", CGRectMake(FVCenter, 0, 100, 100), self.profileImageView = ^{
                UIImageView *imageView = [[UIImageView alloc]init];
                return imageView;
            }()),
        ]],
    ]];

    self.userPanelView.hidden = YES;
    [self.declaration setupViewTreeInto:self.view];

    [self.loginToWeiboButton addTarget:self action:@selector(loginToWeibo:) forControlEvents:UIControlEventTouchUpInside];

    typeof(self) __weak weakSelf = self;
    self.weiboLoginBinding = binding([SLSharedConfig sharedInstance], @"weiboUserLoginInfo", ^(NSObject *value){
        if(value == nil){
            return;
        }
        NSString *accessToken = [SLSharedConfig sharedInstance].weiboUserLoginInfo[@"access_token"];
        NSString *uid = [SLSharedConfig sharedInstance].weiboUserLoginInfo[@"uid"];

        weakSelf.loginToWeiboButton.hidden = YES;
        weakSelf.userPanelView.hidden = NO;

        [WBHttpRequest requestWithAccessToken:accessToken url:@"https://api.weibo.com/2/users/show.json" httpMethod:@"GET" params:@{
            @"uid":uid
        } delegate:weakSelf];
    });

    self.weiboUserBinding = binding([SLSharedConfig sharedInstance], @"weiboUser", ^(NSObject *value){
        if(value == nil){
            return;
        }

        WeiboUserInfo *weiboUser = (WeiboUserInfo *)value;

        weakSelf.title = weiboUser.name;
        [weakSelf.profileImageView setImageWithURL:[NSURL URLWithString:weiboUser.profileImageUrl]];
    });
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.declaration.unExpandedFrame = self.view.bounds;
    [self.declaration updateViewFrame];
}

-(void)loginToWeibo:(id)sender{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURI;
    request.scope = @"all";
    request.userInfo = @{
        @"SSO_From" : @"WordDetailViewController",
    };
    [WeiboSDK sendRequest:request];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.toolbarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbarHidden = NO;
    [super viewWillDisappear:animated];
}

#pragma mark WBHttpRequest
-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    WeiboUserInfo *wbUser = [[WeiboUserInfo alloc] initWithRequestUserInfo:userInfo];
    [SLSharedConfig sharedInstance].weiboUser = wbUser;
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error {
    [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}
@end