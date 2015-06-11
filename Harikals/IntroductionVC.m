//
//  IntroductionVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "IntroductionVC.h"
#import <UIView+Position.h>


@import QuartzCore;

@interface IntroductionVC () <UIScrollViewDelegate> {
    
    __weak IBOutlet UIPageControl *pageControl;
    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UIButton *nextButton;
    NSInteger currentPage;
    __weak IBOutlet UIView *imagesContainer;
    
    __weak IBOutlet UILabel *topLabel;
    NSInteger pageWidth;
    
    NSArray *topTexts;
    
    __weak IBOutlet NSLayoutConstraint *topTextSpace;
    CGFloat adjustingValue;
    __weak IBOutlet NSLayoutConstraint *heightConstraint1;
    
    __weak IBOutlet NSLayoutConstraint *widthConstraint1;
    
    __weak IBOutlet NSLayoutConstraint *heightConstraint2;
    __weak IBOutlet NSLayoutConstraint *widthConstraint2;
}

@end

@implementation IntroductionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    adjustingValue = 24.0;
    mainScrollView.pagingEnabled = YES;
    [self.view addGestureRecognizer:mainScrollView.panGestureRecognizer];
    mainScrollView.userInteractionEnabled = NO;
    
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        topTextSpace.constant = -15;
        pageControl.hidden = YES;
        topLabel.font  = [UIFont fontWithName:@"OpenSans" size:13.0];
    }

    topTexts = @[@"Harikaiş'te bir CV hazırlamıyorsunuz!\nYapmanız gereken tek şey; Linkedin\nhesabınızla giriş yapmak ve bir açık\npozisyon önermemizi beklemek.",
                 @"Teklif ettiğimiz pozisyona hemen\nbaşvurabilir ve başvurunuzun\ndurumunu uygulama içerisinden takip\nedebilirsiniz.",
                 @"Başvurunuz, yüzlerce adayın arasında\nkaybolmayacak! Çünkü, eşsiz eşleştirme\nmotorumuz ile pozisyonları sadece en\nuygun adaylara yönlendiriyoruz.",
                 @"Eğer isterseniz başvurunuz öncesinde,\naçık pozisyonun İK sorumlusu ile anonim\nolarak mesajlaşabilir ve aklınızdaki tüm\nsoruları sorabilirsiniz.",
                 @"Çalıştığınız işyerinin hiç bir şeyden haberi\nolmayacak... İş başvurularınızi yaptığınız\nfirma hariç hiç kimse buraya üye\nolduğunuzu dahi bilemez."];
    
}

- (void)addImages {
    

    
    UIImageView *imageview1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen-image-1"]];
    UIImageView *imageview2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen-image-2"]];
    UIImageView *imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen-image-3"]];
    UIImageView *imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen-image-4"]];
    UIImageView *imageview5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen-image-5"]];
    
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.delegate = self;
    
    imageview1.frameX = adjustingValue / 2.0;
    imageview2.frameX = imageview1.frameRight + adjustingValue;
    imageview3.frameX = imageview2.frameRight + adjustingValue;
    imageview4.frameX = imageview3.frameRight + adjustingValue;
    imageview5.frameX = imageview4.frameRight + adjustingValue;
    
    [imagesContainer addSubview:imageview1];
    [imagesContainer addSubview:imageview2];
    [imagesContainer addSubview:imageview3];
    [imagesContainer addSubview:imageview4];
    [imagesContainer addSubview:imageview5];
    
    imagesContainer.frameWidth = (imageview1.frameWidth + adjustingValue) * 5;
    imagesContainer.frameHeight = imageview1.frameHeight;
    mainScrollView.contentSize = CGSizeMake((imageview1.frameWidth + adjustingValue) * 5, imageview1.frameHeight - 100);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [mainScrollView scrollRectToVisible:CGRectMake(0, 0, pageWidth, 10) animated:NO];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl.currentPage = page;
    currentPage = page;
    [self changeButtonStyle:page == 4];
    [topLabel setText:topTexts[page]];
}


- (void)changeButtonStyle:(BOOL)red {
    if (red) {
        [nextButton setBackgroundImage:[UIImage imageNamed:@"red-button-bg"] forState:UIControlStateNormal];
        [nextButton setTitle:@"TURU SONLANDIR" forState:UIControlStateNormal];
    } else {
        [nextButton setBackgroundImage:[UIImage imageNamed:@"button-bg"] forState:UIControlStateNormal];
        [nextButton setTitle:@"DEVAM ET" forState:UIControlStateNormal];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self addImages];
    [self scrollViewDidScroll:mainScrollView];
    for (int i = 0; i < [pageControl.subviews count]; i++)
    {
        UIView *dotView = [pageControl.subviews objectAtIndex:i];
        dotView.layer.borderColor = [UIColor colorWithRed:72.0 / 255.0 green:160.0 / 255.0 blue:220.0 / 255.0 alpha:1.0].CGColor;
        dotView.layer.borderWidth = 1.0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (IBAction)nextPressed:(UIButton *)sender {
    if (currentPage == 4) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    } else {
        [mainScrollView scrollRectToVisible:CGRectMake(pageWidth * (currentPage + 1), 0, pageWidth, 10) animated:YES];
    }
}


@end
