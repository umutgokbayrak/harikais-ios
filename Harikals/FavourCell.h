//
//  FavourCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FavCellDelegate <NSObject>

- (void)updateImage:(UIImage *)image forJobId:(NSString *)jobId;

@end

@interface FavourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)configureFavourite:(NSDictionary *)favouriteObject;
- (void)configureChat:(NSDictionary *)chatObject;

@property (weak, nonatomic) IBOutlet UIView *counterView;
@property (weak, nonatomic) id <FavCellDelegate> delegate;

@end
