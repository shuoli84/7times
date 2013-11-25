//
//  AppDelegate.m
//  7times
//
//  Created by Li Shuo on 13-9-10.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <FlatUIKit/UIColor+FlatUI.h>
#import "AppDelegate.h"
#import "Flurry.h"
#import "iRate.h"
#import "SevenTimesIAPHelper.h"
#import "WeiboSDK.h"
#import "SLSharedConfig.h"

@interface AppDelegate () <WeiboSDKDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SevenTimesIAPHelper sharedInstance];

    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"CB3JTGXRXMST9B99K452"];
    [Flurry setEventLoggingEnabled:YES];

    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor greenSeaColor]];

    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"2038284123"];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (void)initialize {
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 15;
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"ReceiveWeiboRequest %@", request);
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if([response isKindOfClass:[WBAuthorizeResponse class]]){
        NSString *title = @"认证结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                                                       response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];

        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;

        [SLSharedConfig sharedInstance].weiboUserLoginInfo = authResponse.userInfo;

        [alert show];
    }
}

@end
