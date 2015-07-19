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


@interface InitialVC () <UIAlertViewDelegate> {
    NSString *redirectString;
    
}

@end

@implementation InitialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    Server.firstNavVC = self.navigationController;
    [Server callFunctionInBackground:@"config" withParameters:@{} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems) {
            [self processConfigResponce:receivedItems];
            
            Server.configDictionary = receivedItems;
            Server.linkedInHttpClient =
            [LIALinkedInHttpClient
             clientForApplication:[LIALinkedInApplication applicationWithRedirectURL:receivedItems[@"redirect"][@"ios"]
                                                                            clientId:receivedItems[@"linkedin"][@"clientId"] clientSecret:receivedItems[@"linkedin"][@"clientSecret"]
                                                                               state:@"DCEEFWF45453sdffef424111234" grantedAccess:receivedItems[@"linkedin"][@"permissions"]]];
            
            
        } else {

        }
        
    }];

    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary *userData =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
    
    if (userData) {
        [Server callFunctionInBackground:@"autoLogin" withParameters:@{@"email" : userData[@"email"] , @"userId" : userData[@"userId"], @"authHash" : userData[@"authHash"]} block:^(NSDictionary *receivedItems, NSError *error) {
            if (receivedItems) {
                if ([receivedItems[@"result"] integerValue] == 0) {
                    
                    {{
                        if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"ShownWelcome"]) {
                            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ShownIntro"]) {
                                
                                if ([userData[@"cvComplete"] integerValue] == 0) {
                                    [self performSegueWithIdentifier:@"openCV" sender:nil];
                                } else {
                                    id menuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"menuEmpty"];
                                    [self.navigationController pushViewController:menuVC animated:NO];
                                }
                                
                                
                            } else {
                                [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"intro"] animated:NO];
                            }
                        } else {
                            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"merhaba"] animated:NO];
                        }
                        
                    }}
                    
                } else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userData"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self goToLoginView];
                }
            } else {
                
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
    } else {
        //
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}

- (void)processConfigResponce:(NSDictionary *)responce {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    redirectString = responce[@"redirect"][@"ios"];
    if ([[userDefaults objectForKey:@"ver"] floatValue] < [responce[@"minVersion"] floatValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Bu uygulamanın yeni version mevcuttur. İndirmek ister misiniz?" delegate:self cancelButtonTitle:@"App Store" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
    } else {
        if ([responce[@"announcement"] length]) {
            [Server showWebAlertWithText:responce[@"announcement"]];
        }
    }
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectString]];
    }
}



- (void)showAnouncementWithString:(NSString *)anouncementString {
    
}

- (void)goToLoginView {
    [self performSegueWithIdentifier:@"login" sender:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

@end
