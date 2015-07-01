//
//  MenuCell.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 1/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "MenuCell.h"
#import <UIView+Position.h>
@interface MenuCell () {

}

@end

@implementation MenuCell
@synthesize tintView;

- (void)awakeFromNib {
    tintView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"menu-tint"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)]];
    tintView.frameWidth = 400;
    [self.contentView insertSubview:tintView atIndex:0];
    tintView.alpha = 0.0;
}


-(void)hideTint:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:0 animations:^{
        tintView.alpha = !hide ? 1 : 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
