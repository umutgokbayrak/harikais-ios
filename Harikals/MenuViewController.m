//
//  MenuViewController.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.3;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    self.scaleMenuView = NO;
    self.scaleBackgroundImageView = NO;
    self.fadeMenuView = NO;
    self.contentViewScaleValue = 0.87;
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        self.contentViewInPortraitOffsetCenterX = 80;
    } else if ([UIScreen mainScreen].bounds.size.height == 667){
        self.contentViewInPortraitOffsetCenterX = 100;
    } else if ([UIScreen mainScreen].bounds.size.height == 736){
        self.contentViewInPortraitOffsetCenterX = 110;
    } else {
        self.contentViewInPortraitOffsetCenterX = 80;
    }

    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuViewController"];


    self.delegate = self;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end
