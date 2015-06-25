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

@end

@interface CardView : UIView

@property (nonatomic, weak) IBOutlet UITextView *infoTextView;

@property (nonatomic, weak) id <CardViewDelegate> delegate;
- (void)configureViewWithJob:(NSDictionary *)jobDictionary;

@end
