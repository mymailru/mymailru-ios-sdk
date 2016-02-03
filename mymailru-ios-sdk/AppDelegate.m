//
//  AppDelegate.m
//  mymailru-ios-sdk
//
//  Created by d.taraev on 20.01.16.
//  Copyright © 2016 mail.ru. All rights reserved.
//

#import "AppDelegate.h"
#import "MMSdk.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [MMSdk processOpenURL:url fromApplication:sourceApplication];
    
    return YES;
}

@end
