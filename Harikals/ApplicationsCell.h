//
//  ApplicationsCell.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/22/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationsCell : UITableViewCell

- (void)configureApplication:(NSDictionary *)applicationObject;
- (void)loadAvatarWithLink:(NSString *)link;

@end
