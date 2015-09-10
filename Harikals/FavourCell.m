//
//  FavourCell.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "FavourCell.h"
#import <UIImageView+WebCache.h>
@import QuartzCore;
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@interface FavourCell () {
    
    __weak IBOutlet UILabel *positionLabel;
    __weak IBOutlet UILabel *nameLabel;
    
    __weak IBOutlet UILabel *dateLabel;
    
    NSDictionary *dataDict;
}

@end

@implementation FavourCell
@synthesize avatarImageView;


- (void)awakeFromNib {
    [super awakeFromNib];
    avatarImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureChat:(NSDictionary *)chatObject {
    dataDict = chatObject;
    
    nameLabel.text = chatObject[@"company"];
    dateLabel.text = chatObject[@"lastUpdate"];
    dispatch_async(dispatch_get_main_queue(), ^{
        avatarImageView.image = [UIImage imageNamed:@"avatar"];
    });
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0;
    
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:chatObject[@"profileImage"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([dataDict isEqual:chatObject]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                avatarImageView.image = image;
            });
        }
    }];
}

- (void)configureFavourite:(NSDictionary *)favouriteObject {
    dataDict = favouriteObject;
    
    nameLabel.text = favouriteObject[@"company"];
    positionLabel.text = favouriteObject[@"position"];
    dispatch_async(dispatch_get_main_queue(), ^{
        avatarImageView.image = [UIImage imageNamed:@"company-placeholder"];

    });
    avatarImageView.layer.cornerRadius = 3.0;
    
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:favouriteObject[@"photoUrl"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([dataDict isEqual:favouriteObject]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                avatarImageView.image = image;
                if ([self.delegate respondsToSelector:@selector(updateImage:forJobId:)]) {
                    [self.delegate updateImage:image forJobId:favouriteObject[@"jobId"]];
                }
            });
        }
    }];
    
    
}

@end
