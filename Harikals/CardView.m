//
//  CardView.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "CardView.h"
#import "SPCacheManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CardView () {
    NSDictionary *job;
    
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *positionLabel;
    
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UIImageView *photoImageView;
    __weak IBOutlet UITextView *infoTextView;
    
    __weak IBOutlet UILabel *codeLabel;
}

@end

@implementation CardView

//{
//    company =     {
//        info = "Trivia Software bla ipsum dolor sit amet, consectetur adipiscing elit. Sed vel risus mi, sit amet porta sem. Vivamus sed ornare libero. Maecenas nec velit diam, commodo viverra enim. ";
//        location = "\U0130stanbul, Anadolu Yakas\U0131";
//        name = "Trivia Software A.G";
//        photoUrl = "http://www.harikais.com/img/office.jpg";
//    };
//    flags =     {
//        applied = 0;
//        favorited = 0;
//    };
//    id = 12345;
//    job =     {
//        info = "<p>Senior ipsum dolor sit amet, consectetur adipiscing elit.<p><ul><li>Sed vel risus mi,</li> <li>Sit amet porta sem.</li> <li>Vivamus sed ornare libero.</li> <li>Maecenas nec velit diam, </li></ul><p>Phasellus non enim sapien, eu vulputate libero. In vitae justo erat. Mauris luctus pharetra sem quis scelerisque.</p>";
//        position = "Senior Java Developer";
//        salaryBegin = 2000TL;
//        salaryEnd = 2500TL;
//    };
//    shortInfo = "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel risus mi, sit amet porta sem. Vivamus sed ornare libero.</p> <p>Maecenas nec velit diam, commodo viverra enim. Mauris arcu orci, consectetur non porta eu, lobortis eu lorem.</p>";
//},

-(void)awakeFromNib {
    [super awakeFromNib];

//    photoImageView.layer.shouldRasterize = YES;
//    photoImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    photoImageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;

}


- (void)configureViewWithJob:(NSDictionary *)jobDictionary {
    if (job != jobDictionary) {
        NSDictionary *jobInfo = jobDictionary[@"job"];
        NSDictionary *companyInfo = jobDictionary[@"company"];

        codeLabel.text = [NSString stringWithFormat:@"Ücret Skalası: %@%@", jobInfo[@"salaryBegin"], jobInfo[@"salaryEnd"] ? [NSString stringWithFormat:@" - %@", jobInfo[@"salaryEnd"]]  : @""];

        positionLabel.text = jobInfo[@"position"];
        nameLabel.text = companyInfo[@"name"];
        locationLabel.text = companyInfo[@"location"];

        [infoTextView scrollRectToVisible:CGRectZero animated:NO];
//        infoTextView.text = [NSString stringWithFormat:@"%@\n\n%@", companyInfo[@"info"], jobInfo[@"info"]];
        infoTextView.text = jobDictionary[@"shortInfo"];
        
        infoTextView.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
        photoImageView.image = [UIImage imageNamed:@"company-placeholder"];
        
        [photoImageView sd_setImageWithURL:[NSURL URLWithString:companyInfo[@"photoUrl"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([job isEqual:jobDictionary]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    photoImageView.image = image;
                });
            }
        }];
        job = jobDictionary;
    }
    

}

@end
