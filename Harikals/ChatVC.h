//
//  ChatVC.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatVC : UIViewController
@property (readwrite, retain) UIView *inputAccessoryView;

@property (nonatomic, assign) BOOL fromDetail;

@property (nonatomic, strong) NSDictionary *dataDictionary;

@end
