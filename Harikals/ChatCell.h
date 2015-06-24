//
//  ChatCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/23/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UIImageView *cloudMeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudOtherImageView;


@end
