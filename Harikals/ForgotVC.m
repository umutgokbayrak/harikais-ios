//
//  ForgotVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/19/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ForgotVC.h"
#import "HKTextField.h"
#import "HKServer.h"

@interface ForgotVC () <UITextFieldDelegate> {
    NSString *placeHolderRed;
    NSString *placeHolderGreen;
    
    NSString *firstTitle;
    NSString *secondTitle;
    
    UIColor *greenColor;
    UIColor *redColor;
    
    __weak IBOutlet UIView *tintView;
    __weak IBOutlet UIButton *tamamButton;
    __weak IBOutlet HKTextField *emailTextField;
    
    __weak IBOutlet NSLayoutConstraint *holderVertical;
    __weak IBOutlet UILabel *topTitleLabel;
    
    BOOL isRed;
}

@end

@implementation ForgotVC

- (void)viewDidLoad {
    [super viewDidLoad];
    placeHolderRed = @"tekrar deneyiniz";
    placeHolderGreen = @"e-posta";
    
    firstTitle = @"E-posta adresinizi giriniz";
    secondTitle = @"Bu e-posta adresi kayıtlı değil";
    emailTextField.delegate = self;
    emailTextField.layer.borderWidth = 0.5;
    emailTextField.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    redColor = [UIColor colorWithRed:237.0 / 255.0 green:113.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:136.0 / 255.0 green:192.0 / 255.0 blue:87.0 / 255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)]];

}

- (void)hideSelf {
    [self.view endEditing:YES];
    self.view.window.hidden = YES;
}

- (BOOL)validateEmail:(NSString *)tempMail {
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:tempMail];
}

- (IBAction)sendPressed:(id)sender {
    if (!emailTextField.text.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen bir eposta adresi giriniz" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [self switchToRed];
        return;
    }
    
    
    if ([self validateEmail:emailTextField.text]) {
        [self.view endEditing:YES];
        [self.view.window setHidden:YES];
        NSString *email = emailTextField.text;
        
        [Server callFunctionInBackground:@"forgotPassword" withParameters:@{@"email" : email} block:^(NSDictionary *receivedItems, NSError *error) {
            if (receivedItems) {
                
                if ([receivedItems[@"result"] integerValue] == 0) {
                    [Server showAlertWithText:@"E-posta adresinize şifrenizi\nsıfırlamak için gerekli bilgiler\ngönderilmiştir." closeButton:@"KAPAT"];
                    
                    
                } else if ([receivedItems[@"result"] integerValue] != 0) {
                    if ([receivedItems[@"msg"] length]) {
                        [self showAlertWithText:receivedItems[@"msg"]];
                    }
                }
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen geçerli bir eposta adresi giriniz" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [self switchToRed];
    }
    
}

- (void)showAlertWithText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

-(void)switchToGreen {
    isRed = NO;
    topTitleLabel.text = firstTitle;
    emailTextField.text = @"";
    emailTextField.placeholder = placeHolderGreen;
    [tamamButton setBackgroundColor:greenColor];
}

-(void)switchToRed {
    isRed = YES;
    topTitleLabel.text = secondTitle;
    emailTextField.placeholder = placeHolderRed;
    [tamamButton setBackgroundColor:redColor];
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self.view layoutIfNeeded];
    
    holderVertical.constant =  MIN(self.view.frame.size.height - keyboardEndFrame.origin.y, 150);
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"ForgotVC";
}


@end
