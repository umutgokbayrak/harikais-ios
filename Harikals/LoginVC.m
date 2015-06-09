//
//  LoginVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/9/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC () {
    __weak IBOutlet NSLayoutConstraint *tipVerticalSpacing;
    
    __weak IBOutlet UIImageView *tooltipView;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self animateTip];
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
