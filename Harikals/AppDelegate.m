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
#import "ForgotVC.h"
#import "AlertVC.h"
#import <SplunkMint-iOS/SplunkMint-iOS.h>



@interface AppDelegate () {
    
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.forgotPassWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.forgotPassWindow.rootViewController  = [[ForgotVC alloc] initWithNibName:@"ForgotView" bundle:nil];
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[AlertVC alloc] initWithNibName:@"AlertVCView" bundle:nil];
    
    [[Mint sharedInstance] initAndStartSession:@"95271da7"];
    [Parse setApplicationId:@"7EqNvrRwIHC2CP34qAgVJTCCmmReT5gnZdZM5zYP" clientKey:@"z7OlXSHBV5KJXdkPbx9xh9XDGrcsWOkj3V0sn9xn"];

    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Semibold" size:17.0]}];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@1.1 forKey:@"ver"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerAppForNotifications) name:@"registerAppForNotifications" object:nil];
    
    return YES;
}

-(void)registerAppForNotifications{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (Server.userInfoDictionary) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"%@%@", @"CHN-", Server.userInfoDictionary[@"userId"]] forKey:@"channels"];
//        [currentInstallation saveInBackground];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                NSLog(@"subsribed user to channel");
            } else {
                NSLog(@"error subscribing user to channel: %@", error);
            }
        }];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
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
