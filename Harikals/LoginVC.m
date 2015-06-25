//
//  LoginVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/9/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "LoginVC.h"
#import <PFLinkedInUtils.h>


@interface LoginVC () {
    __weak IBOutlet NSLayoutConstraint *tipVerticalSpacing;
    
    __weak IBOutlet UIImageView *tooltipView;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser][@"linkedInUser"] && [[PFUser currentUser][@"username"] length]) {
        [self performSegueWithIdentifier:@"noAnim" sender:nil];
    }
  
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self animateTip];  
}

- (IBAction)loginPressed:(id)sender {
//    spinner
    
    [PFLinkedInUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (user) {
            [self performSegueWithIdentifier:@"login" sender:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps..." message:error.description delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alert show];
        }
        
////        [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken]
//        
//        [PFLinkedInUtils.linkedInHttpClient GET:@"companies" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
////            NSLog(@"Response JSON: %@", responseObject);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////            NSLog(@"Error: %@", error);
//        }];
    }];
}


- (void)animateTip {
    [self.view layoutIfNeeded];
    tipVerticalSpacing.constant = 8;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    
    }];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
