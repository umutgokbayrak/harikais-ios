//
//  InitialVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "InitialVC.h"
#import <PFLinkedInUtils.h>
#import "HKServer.h"
#import <IOSLinkedInAPI/LIALinkedInApplication.h>


@interface InitialVC ()

@end

@implementation InitialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    Server.firstNavVC = self.navigationController;
    [Server callFunctionInBackground:@"config" withParameters:@{} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems) {
            Server.configDictionary = receivedItems;
            Server.linkedInHttpClient =
            [LIALinkedInHttpClient
             clientForApplication:[LIALinkedInApplication applicationWithRedirectURL:receivedItems[@"redirect"][@"ios"]
                                                                            clientId:receivedItems[@"linkedin"][@"clientId"] clientSecret:receivedItems[@"linkedin"][@"clientSecret"]
                                                                               state:@"aaaabbbbccccdddd" grantedAccess:receivedItems[@"linkedin"][@"permissions"]]];
            
            
//            [self performSegueWithIdentifier:@"openCV" sender:nil];
        } else {
            //TODO:Remove NSLog
            NSLog(@"%@", error);
        }
        
    }];

//    [[NSUserDefaults standardUserDefaults] setObject:@{@"authHash" : receivedItems[@"authHash"],
//                                                       @"userId" : receivedItems[@"userId"]
//                                                       } forKey:@"userData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userData"]) {
        
        
        // autologin
        {{
            if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"ShownWelcome"]) {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ShownIntro"]) {
                    
                    [self performSegueWithIdentifier:@"openCV" sender:nil];
                    
                } else {
                    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"intro"] animated:NO];
                }
            } else {
                [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"merhaba"] animated:NO];
            }
            
        }}
        
    } else {
        //
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
