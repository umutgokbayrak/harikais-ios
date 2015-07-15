//
//  ProfileCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *greenTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chekImageView;

@property (weak, nonatomic) IBOutlet UITextField *inTextField;


@end
