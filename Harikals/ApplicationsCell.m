//
//  ApplicationsCell.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/22/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ApplicationsCell.h"
#import <UIImageView+WebCache.h>
#import <UIView+Position.h>

@interface ApplicationsCell () {
    
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *companyName;
    __weak IBOutlet UIImageView *iconImageView;
    __weak IBOutlet UIImageView *avatarImageView;
    __weak IBOutlet UILabel *positionLabel;
    
    UIImage *avaImage;
}

@end


@implementation ApplicationsCell

- (void)awakeFromNib {
    // Initialization code
    avatarImageView.layer.cornerRadius = avatarImageView.frameWidth / 2.0;
    avatarImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureApplication:(NSDictionary *)applicationObject {
    companyName.text = applicationObject[@"company"];
    positionLabel.text = applicationObject[@"position"];
    iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon", applicationObject[@"icon"]]];
    timeLabel.text = applicationObject[@"date"];
}

- (void)loadAvatarWithLink:(NSString *)link {
        [avatarImageView sd_setImageWithURL:[NSURL URLWithString:link] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            avaImage = image;
        }];
}

@end
