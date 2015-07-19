//
//  AlertVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/19/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "AlertVC.h"

@interface AlertVC ()

@end

@implementation AlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf:)]];
    
}

- (IBAction)hideSelf:(id)sender {
    self.view.window.hidden = YES;
}

@end
