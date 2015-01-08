//
//  MenuCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 1/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
@property (nonatomic, strong) UIImageView *tintView;

- (void)hideTint:(BOOL)hide;

@end
