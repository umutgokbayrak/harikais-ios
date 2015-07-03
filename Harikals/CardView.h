//
//  CardView.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardViewDelegate <NSObject>

- (void)updateImage:(UIImage *)image forJobId:(NSString *)jobId;
- (void)detailPressed;

@end

@interface CardView : UIView

@property (nonatomic, weak) IBOutlet UITextView *infoTextView;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;

@property (nonatomic, weak) IBOutlet UILabel *codeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *pinIcon;


@property (nonatomic, weak) id <CardViewDelegate> delegate;
- (void)configureViewWithJob:(NSDictionary *)jobDictionary;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

@property (weak, nonatomic) IBOutlet UIButton *detailarButton;

@end
