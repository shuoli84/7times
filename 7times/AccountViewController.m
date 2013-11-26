//
// Created by Li Shuo on 13-11-24.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <SLFlexibleView/FVDeclareHelper.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>
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
@property (nonatomic, strong) UIButton *shareToWeiboButton;
@property (nonatomic, strong) UIButton *logoutButton;

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
        [dec(@"weiboUser", CGRectMake(FVCenter, FVCenter, FVP(0.6), 400), self.userPanelView = [UIView new]) $:@[
            dec(@"userProfileImage", CGRectMake(FVCenter, 0, 100, 100), self.profileImageView = ^{
                UIImageView *imageView = [[UIImageView alloc]init];
                return imageView;
            }()),
            dec(@"shareToFriends", CGRectMake(FVCenter, FVA(20), FVP(0.8), 50), self.shareToWeiboButton = ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

            [button setTitle:@"分享到微博" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
            button.backgroundColor = [UIColor greenSeaColor];
                [button addEventHandler:^(id sender) {
                    WBMessageObject *message = [WBMessageObject message];
                    message.text = [NSString stringWithFormat:@"正在用7times背单词，小伙伴们一起来吧。https://itunes.apple.com/us/app/7times/id728175596?ls=1&mt=8"];
                    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
                    [WeiboSDK sendRequest:request];
                } forControlEvents:UIControlEventTouchUpInside];

                return button;
        }()),
            dec(@"logout", CGRectMake(FVCenter, FVA(20), FVP(0.8), 50), self.logoutButton = ^{
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

            [button setTitle:@"取消授权" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            button.backgroundColor = [UIColor alizarinColor];
                [button addEventHandler:^(id sender) {
                    NSLog(@"Logout");
                    [WeiboSDK logOutWithToken:[SLSharedConfig sharedInstance].weiboUserLoginInfo[@"access_token"] delegate:self];
                    [SLSharedConfig sharedInstance].weiboUserLoginInfo = nil;
                    [SLSharedConfig sharedInstance].weiboUser = nil;
                } forControlEvents:UIControlEventTouchUpInside];

                return button;
        }()),
        ]],
    ]];

    self.userPanelView.hidden = YES;
    [self.declaration setupViewTreeInto:self.view];

    [self.loginToWeiboButton addTarget:self action:@selector(loginToWeibo:) forControlEvents:UIControlEventTouchUpInside];
    
    typeof(self) __weak weakSelf = self;
    self.weiboLoginBinding = binding([SLSharedConfig sharedInstance], @"weiboUserLoginInfo", ^(NSObject *value){
        if(value == nil){
            weakSelf.loginToWeiboButton.hidden = NO;
            weakSelf.userPanelView.hidden = YES;
        }
        else{
            NSString *accessToken = [SLSharedConfig sharedInstance].weiboUserLoginInfo[@"access_token"];
            NSString *uid = [SLSharedConfig sharedInstance].weiboUserLoginInfo[@"uid"];

            weakSelf.loginToWeiboButton.hidden = YES;
            weakSelf.userPanelView.hidden = NO;

            [WBHttpRequest requestWithAccessToken:accessToken url:@"https://api.weibo.com/2/users/show.json" httpMethod:@"GET" params:@{
                @"uid":uid
            } delegate:weakSelf];
        }
    });

    self.weiboUserBinding = binding([SLSharedConfig sharedInstance], @"weiboUser", ^(NSObject *value){
        if(value == nil){
            return;
        }
        else{
            WeiboUserInfo *weiboUser = (WeiboUserInfo *)value;

            weakSelf.title = weiboUser.name;
            [weakSelf.profileImageView setImageWithURL:[NSURL URLWithString:weiboUser.profileImageUrl]];
        }
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
-(void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"Response received: %@", response);
}

-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
    NSLog(@"Request finished: %@", result);
    if([request isKindOfClass:[WBHttpRequest class]]){
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        WeiboUserInfo *wbUser = [[WeiboUserInfo alloc] initWithRequestUserInfo:userInfo];
        [SLSharedConfig sharedInstance].weiboUser = wbUser;
    }
    else{
        NSLog(@"xx");
    }
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error {
    [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}
@end