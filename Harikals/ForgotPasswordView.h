//
//  ForgotPasswordView.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTextField.h"
@interface ForgotPasswordView : UIView
@property (strong, nonatomic) IBOutlet UIView *tintView;

@property (strong, nonatomic) IBOutlet UIView *holderView;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet HKTextField *emailTextField;

@end
