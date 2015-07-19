//
//  AlertVC.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/19/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIView *mainAlertHolder;

@property (weak, nonatomic) IBOutlet UIView *favouriteAlertHolder;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryText;

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@property (weak, nonatomic) IBOutlet UIView *webHolder;


@end
