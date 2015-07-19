//
//  IntroductionVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/8/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "IntroductionVC.h"
#import <UIView+Position.h>
#import <Parse.h>
#import "HKServer.h"
@import QuartzCore;

@interface IntroductionVC () <UIScrollViewDelegate> {
    
    
    __weak IBOutlet NSLayoutConstraint *contentWidth;
    
    __weak IBOutlet UIPageControl *pageControl;
    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UIButton *nextButton;
    NSInteger currentPage;
    __weak IBOutlet UIView *imagesContainer;
    
    __weak IBOutlet UILabel *topLabel;
    NSInteger pageWidth;
    
    NSArray *topTexts;
    
    
    NSArray *attributedLines;
    
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
//    if ([PFUser currentUser][@"linkedInUser"] && [[PFUser currentUser][@"username"] length]) {
//        [self performSegueWithIdentifier:@"noAnim" sender:nil];
//    }
    
    adjustingValue = 24.0;
    mainScrollView.pagingEnabled = YES;
    [self.view addGestureRecognizer:mainScrollView.panGestureRecognizer];
    mainScrollView.userInteractionEnabled = NO;
    
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        topTextSpace.constant = -15;
        pageControl.hidden = YES;
        topLabel.font  = [UIFont fontWithName:@"OpenSans" size:13.0];
    }

    topTexts = @[@"Harikaiş’te CV oluşturmak çok kolay!\nSonrasında yapmanız gereken tek şey\nsize bir pozisyon önermemizi beklemek.\nAktif arayışta olmasanız dahi fark etmez.\n“Belki de iyi bir teklif gelir…”",
                 
                 @"Teklif ettiğimiz pozisyona hemen\nbaşvurabilir ve başvurunuzun\ndurumunu uygulama içerisinden takip\nedebilirsiniz.",
                 
                 @"Başvurunuz, yüzlerce adayın arasında\nkaybolmayacak! Çünkü, eşsiz eşleştirme\nmotorumuz ile pozisyonları sadece en\nuygun adaylara yönlendiriyoruz.",
                 
                 @"Eğer isterseniz başvurunuz öncesinde,\naçık pozisyonun İK sorumlusu ile\nkimliğiniz gizli olarak mesajlaşabilir ve\naklınızdaki tüm soruları sorabilirsiniz.",
                 
                 @"Çalıştığınız işyerinin hiç bir şeyden haberi\nolmayacak... İş başvurularınızi yaptığınız\nfirma hariç hiç kimse buraya üye\nolduğunuzu bilemez."];
    
    
    attributedLines = @[@"CV oluşturmak çok kolay", @"başvurunuzun", @"durumunu", @"sadece en", @"uygun adaylara", @"kimliğiniz gizli olarak",@"kimse buraya üye", @"olduğunuzu bilemez"];
    
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
    mainScrollView.contentSize = CGSizeMake((imageview1.frameWidth + adjustingValue) * 5, 0);
    contentWidth.constant = (imageview1.frameWidth + adjustingValue) * 5;
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
    
    if (page < topTexts.count) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:topTexts[page]];
        [attr addAttribute:NSFontAttributeName value:topLabel.font range:NSMakeRange(0, attr.length)];
        UIColor *redColor = [UIColor colorWithRed:237.0 / 255.0 green:113.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
        UIFont *boldFont =  [UIFont fontWithName:@"OpenSans-Bold" size:15];
        for (NSString *bolded in attributedLines) {
            NSRange range = [topTexts[page] rangeOfString:bolded];
            if (range.length) {
                [attr addAttribute:NSFontAttributeName value:boldFont range:range];
                [attr addAttribute:NSForegroundColorAttributeName value:redColor range:range];
            }
        }
        topLabel.attributedText = attr;
    }
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
    if (currentPage >= 4) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"ShownIntro"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([Server.userInfoDictionary[@"cvComplete"] integerValue] > 0) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"menuEmpty"] animated:YES];
        } else {
            [self performSegueWithIdentifier:@"openCV" sender:nil];
        }
    } else {
        [mainScrollView setContentOffset:CGPointMake(pageWidth * (currentPage + 1), 0) animated:YES];
    }
}


@end
