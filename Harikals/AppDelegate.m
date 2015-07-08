//
//  AppDelegate.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "AppDelegate.h"
#import <PFLinkedInUtils.h>
#import "HKServer.h"
#import <IOSLinkedInAPI/LIALinkedInApplication.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"7EqNvrRwIHC2CP34qAgVJTCCmmReT5gnZdZM5zYP" clientKey:@"z7OlXSHBV5KJXdkPbx9xh9XDGrcsWOkj3V0sn9xn"];
//    [PFLinkedInUtils initializeWithRedirectURL:@"http://www.rundewoo.com" clientId:@"77p3qgyayt2mjo" clientSecret:@"ZQ2HHMY2AdU1JmaX" state:@"aaaabbbbccccdddd" grantedAccess:@[@"r_emailaddress", @"r_basicprofile"] presentingViewController:nil];

    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Semibold" size:17.0]}];
    
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
