//
//  CardsVC.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/9/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"



@interface CardsVC : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *menuButton;


@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIBarItem *orientationBarItem;
@property (nonatomic, strong) IBOutlet UIBarItem *wrapBarItem;

@end
