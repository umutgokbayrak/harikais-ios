//
//  ProfileCell.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (_chekImageView) {
        _chekImageView.hidden = !selected;
    }
}

@end
