//
//  CardView.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "CardView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CardView () <UIWebViewDelegate> {
    NSDictionary *job;
}

@end

@implementation CardView
@synthesize infoTextView, nameLabel, pinIcon, positionLabel, locationLabel, photoImageView, codeLabel;


-(void)awakeFromNib {
    [super awakeFromNib];
    [_detailarButton addTarget:self action:@selector(detailPressed) forControlEvents:UIControlEventTouchUpInside];
//    photoImageView.layer.shouldRasterize = YES;
//    photoImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    photoImageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;

}

- (void)detailPressed {
    if ([self.delegate respondsToSelector:@selector(detailPressed)]) {
        [self.delegate detailPressed];
    }
}

- (void)configureViewWithJob:(NSDictionary *)jobDictionary {
    if (job != jobDictionary) {
        self.hidden = YES;
        NSDictionary *jobInfo = jobDictionary[@"job"];
        NSDictionary *companyInfo = jobDictionary[@"company"];
        _contentWebView.delegate = self;
        codeLabel.text = [NSString stringWithFormat:@"Ücret Skalası: %@%@", jobInfo[@"salaryBegin"], jobInfo[@"salaryEnd"] ? [NSString stringWithFormat:@" - %@", jobInfo[@"salaryEnd"]]  : @""];
        _contentWebView.opaque = NO;
        _contentWebView.backgroundColor = [UIColor clearColor];
        positionLabel.text = jobInfo[@"position"];
        nameLabel.text = companyInfo[@"name"];
        locationLabel.text = companyInfo[@"location"];

        [_contentWebView.scrollView scrollRectToVisible:CGRectZero animated:NO];
        [self configureText:jobDictionary[@"shortInfo"]];
        
        photoImageView.image = [UIImage imageNamed:@"company-placeholder"];
        
        [photoImageView sd_setImageWithURL:[NSURL URLWithString:companyInfo[@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"company-placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([job isEqual:jobDictionary]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    photoImageView.image = image;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkForShowing" object:nil];
                });
                
            }
            if ([self.delegate respondsToSelector:@selector(updateImage:forJobId:)]) {
                [self.delegate updateImage:image forJobId:jobDictionary[@"id"]];
            }

        }];
        job = jobDictionary;
    }

}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    self.hidden = NO;
}

- (void)configureText:(NSString *)text {
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"OpenSans-Light", @14, text];
    

    [_contentWebView loadHTMLString:myDescriptionHTML baseURL:nil];

}


    


@end
