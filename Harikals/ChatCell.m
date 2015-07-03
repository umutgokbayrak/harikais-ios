//
//  ChatCell.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/23/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cloudMeImageView.image = [self.cloudMeImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    self.cloudOtherImageView.image = [self.cloudOtherImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
