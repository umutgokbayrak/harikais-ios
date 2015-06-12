//
//  SettingsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC () {
    
    __weak IBOutlet UIView *middleHolder;
    __weak IBOutlet UIView *topHolder;
}

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    middleHolder.layer.borderWidth = 0.5;
    middleHolder.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    middleHolder.layer.cornerRadius =  3;
    
    topHolder.layer.borderWidth = 0.5;
    topHolder.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    topHolder.layer.cornerRadius =  3;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71.0 / 255.0 green:160.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]];
}

@end
