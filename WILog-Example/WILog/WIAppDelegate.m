//
//  WIAppDelegate.m
//  WILog
//
//  Created by zyp on 01/29/2021.
//  Copyright (c) 2021 zyp. All rights reserved.
//

#import "WIAppDelegate.h"
#import <WILog/WILog.h>

@implementation WIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WILog initLog:WILogLevelDebug withType:WILogTypeFile|WILogTypeDefault withDir:nil];
    [WILog setPrefixName:@"WI"];
    WILogDebug(@"test=%@",@"2375468658");
    WILogExError(@"SDKError0-%@",@"测试error");
    WILogExDebug(@"WILogSDKDebug-%@",@"hahahahha");
    WILogExInfo(@"测试info");

    WILogTagError(@"测试tag", @"12345-%@",@"ceshi");
    WILogTagDebug(@"测试tag", @"12345-%@",@"ceshi");
    WILogTagInfo( @"测试tag", @"12345-%@",@"ceshi");
    
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

@end
