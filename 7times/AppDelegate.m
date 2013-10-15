//
//  AppDelegate.m
//  7times
//
//  Created by Li Shuo on 13-9-10.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "AppDelegate.h"
#import "SLSharedConfig.h"
#import "Flurry.h"
#import "iRate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"CB3JTGXRXMST9B99K452"];
    [Flurry setEventLoggingEnabled:YES];

    [MagicalRecord setupCoreDataStackWithiCloudContainer:@"Q658KUUNJA.com.menic.7times" contentNameKey:@"data" localStoreNamed:@"local.1.0.sqlite" cloudStorePathComponent:@"data" completion:^{
        //Send a notification
        NSLog(@"Core data context setup ready");
        if([SLSharedConfig sharedInstance].coreDataReady){
            [SLSharedConfig sharedInstance].coreDataReady();
        }
    }];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(void)initialize {
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 15;
}

@end
