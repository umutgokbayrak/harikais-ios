//
//  SignInVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/4/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "SignInVC.h"
#import "HKServer.h"
#import "ForgotPasswordView.h"
#import <UIView+Position.h>


@interface SignInVC () <UITextFieldDelegate> {
    
    __weak IBOutlet UILabel *placeLabel3;
    __weak IBOutlet UILabel *placeLabel2;
    __weak IBOutlet UILabel *placeLabel1;
    __weak IBOutlet UITextField *emailTextField;
    
    __weak IBOutlet UITextField *passTextField;
    
    __weak IBOutlet UITextField *confirmPassTextField;
    
    
    __weak IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
    CGFloat baseValue;
    

    IBOutlet ForgotPasswordView *doneForgot;
    IBOutlet ForgotPasswordView *redForgot;
    IBOutlet ForgotPasswordView *greenForgot;

    __weak IBOutlet HKTextField *greenField;
    __weak IBOutlet UIButton *greenSend;
    
    __weak IBOutlet HKTextField *redField;
    
    __weak IBOutlet UIButton *redSend;
    
    
    __weak IBOutlet UIButton *doneButton;
    
    CGFloat baseTopGreen;
    CGFloat baseTopRed;

}

@end

@implementation SignInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    baseValue  = verticalSpaceConstraint.constant;
    emailTextField.delegate = self;
    passTextField.delegate = self;
    confirmPassTextField.delegate = self;

    [emailTextField addTarget:self action:@selector(textFieldDidChange:)       forControlEvents:UIControlEventEditingChanged];
    [passTextField addTarget:self action:@selector(textFieldDidChange:)       forControlEvents:UIControlEventEditingChanged];
    [confirmPassTextField addTarget:self action:@selector(textFieldDidChange:)       forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}


- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardStartFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGFloat delta = keyboardEndFrame.origin.y - keyboardStartFrame.origin.y;
    
    if (!greenForgot.superview) {
        [self.view layoutIfNeeded];
        
        verticalSpaceConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y + baseValue;
    }
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{

        [self adjustForgotWithDelta:delta];
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    
}

- (void)adjustForgotWithDelta:(CGFloat)delta {
    if (greenForgot) {
        ((UIView *)greenForgot.subviews[1]).frameY = fabs(delta) > 100 && delta > 0 ? baseTopGreen : 30;
        ((UIView *)redForgot.subviews[1]).frameY = fabs(delta) > 100 && delta > 0 ? baseTopRed : 30;
    }
}


- (void)textFieldDidChange:(UITextField *)field {
    placeLabel1.hidden = emailTextField.text.length;
    placeLabel2.hidden = passTextField.text.length;
    placeLabel3.hidden = confirmPassTextField.text.length;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)updateUserInfo {
    
    [self perfirmLoginAction];
    
}

- (IBAction)forgotPassPressed:(id)sender {
//    if (!greenForgot) {
//        [self loadModalViews];
//        
//        greenForgot.frame = [UIScreen mainScreen].bounds;
//        greenForgot.holderView.frameY = baseTopGreen;
// 
//        [self.navigationController.view addSubview:greenForgot];
//    }
    
}

- (void)showRedForgotView {
    redForgot.frame = [UIScreen mainScreen].bounds;
    redForgot.holderView.frameY = baseTopRed;
    
    [self.navigationController.view addSubview:redForgot];
}

- (void)showDoneView {
    doneForgot.frame = [UIScreen mainScreen].bounds;
    [self.navigationController.view addSubview:doneForgot];
}

- (void)sendForgot {
    [self.view endEditing:YES];
    [self hideModals];
}

- (void)hideModals {
    [redForgot removeFromSuperview];
    [greenForgot removeFromSuperview];
    [doneForgot removeFromSuperview];
}

- (void)loadModalViews {
//    greenForgot = [[NSBundle mainBundle] loadNibNamed:@"ForgotView" owner:nil options:nil][1];
//    redForgot = [[NSBundle mainBundle] loadNibNamed:@"ForgotView" owner:nil options:nil][0];
//    doneForgot = [[NSBundle mainBundle] loadNibNamed:@"ForgotView" owner:nil options:nil][2];

    
    [[NSBundle mainBundle] loadNibNamed:@"ForgotView" owner:nil options:nil];
    
    for (HKTextField *view in @[greenField, redField]) {
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    }
    
    [greenSend addTarget:self action:@selector(sendForgot) forControlEvents:UIControlEventTouchUpInside];
    [redSend addTarget:self action:@selector(sendForgot) forControlEvents:UIControlEventTouchUpInside];
        [doneButton addTarget:self action:@selector(hideModals) forControlEvents:UIControlEventTouchUpInside];

    
    baseTopRed= redForgot.holderView.frameY;
    baseTopGreen= greenForgot.holderView.frameY;
}


- (IBAction)loginPressed:(UIButton *)sender {
        sender.userInteractionEnabled = NO;
    if (emailTextField.text.length && passTextField.text.length) {
        
#warning remove it when become working!
        
        //TODO:Remove NSLog
        [self updateUserInfo];
        
        
        [Server callFunctionInBackground:@"login" withParameters:@{@"email" : emailTextField.text , @"password" : passTextField.text} block:^(NSDictionary *receivedItems, NSError *error) {
            if (receivedItems) {
                //TODO:Remove NSLog
                NSLog(@"%@", receivedItems);
                if ([receivedItems[@"result"] integerValue] == 0) {
#warning uncomment when become working!
//                    [self updateUserInfo];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:receivedItems[@"msg"] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                    [alert show];
                }
            } else {

                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }

            sender.userInteractionEnabled = YES;
        }];
    } else {
        sender.userInteractionEnabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bilgileri kontrol edip tekrar deneyiniz." message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    }
}


- (IBAction)switchToSignUp:(id)sender {
//    [self performSegueWithIdentifier:@"signUp" sender:nil];
    SignInVC *sIn = [self.storyboard instantiateViewControllerWithIdentifier:@"signUp"];
    sIn.view.hidden = NO;
    [self.view endEditing:YES];
    [UIView  transitionWithView:self.navigationController.view duration:0.6  options:UIViewAnimationOptionTransitionFlipFromRight
                     animations:^(void) {
                         BOOL oldState = [UIView areAnimationsEnabled];
                         [UIView setAnimationsEnabled:NO];
                         [self.navigationController pushViewController:sIn animated:NO];
                         [UIView setAnimationsEnabled:oldState];
                     }
                     completion:nil];
}

- (void)perfirmLoginAction {
    [self.view endEditing:YES];
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"ShownWelcome"]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ShownIntro"]) {
            
            [self performSegueWithIdentifier:@"openCV" sender:nil];
            
        } else {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"intro"] animated:YES];
        }
    } else {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"merhaba"] animated:YES];
    }
    
    
    
    
//    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"menuEmpty"] animated:YES];
}

- (IBAction)signUpPressed:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    if ([self validateEmail:emailTextField.text]) {
        if (passTextField.text.length >= 6) {
            if ([passTextField.text isEqualToString:confirmPassTextField.text]) {
                [Server callFunctionInBackground:@"createUser" withParameters:@{@"email" : emailTextField.text , @"password" : passTextField.text} block:^(NSDictionary *receivedItems, NSError *error) {
                    if (receivedItems) {
                        //TODO:Remove NSLog
                        NSLog(@"%@", receivedItems);
                        if ([receivedItems[@"result"] integerValue] == 0) {
                            [[NSUserDefaults standardUserDefaults] setObject:@{@"authHash" : receivedItems[@"authHash"],
                                                                               @"userId" : receivedItems[@"userId"]
                                                                               } forKey:@"userData"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [self perfirmLoginAction];
                        }
                    } else {
                        //TODO:Remove NSLog
                        NSLog(@"%@", error);
                    }
                    sender.userInteractionEnabled = YES;
                }];
                sender.userInteractionEnabled = YES;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password not confirmed" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                [alert show];
                sender.userInteractionEnabled = YES;
            }
        } else {
            sender.userInteractionEnabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Şifreniz 6 karakterden kısa olmamalı" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid e-mail" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        sender.userInteractionEnabled = YES;
    }
}

- (BOOL)validateEmail:(NSString *)tempMail {
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:tempMail];
}

- (IBAction)switchToLoginPressed:(id)sender {
    [self.view endEditing:YES];
    [UIView  transitionWithView:self.navigationController.view duration:0.6  options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^(void) {
                         BOOL oldState = [UIView areAnimationsEnabled];
                         [UIView setAnimationsEnabled:NO];
                         [self.navigationController popViewControllerAnimated:NO];
                         [UIView setAnimationsEnabled:oldState];
                     }
                     completion:nil];
}

@end
