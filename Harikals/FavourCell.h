//
//  FavourCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)configureFavourite:(NSDictionary *)favouriteObject;
- (void)configureChat:(NSDictionary *)chatObject;

@property (weak, nonatomic) IBOutlet UIView *counterView;

@end
