//
//  DetailVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/11/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "DetailVC.h"
#import "ChatVC.h"
#import <UIImageView+WebCache.h>
#import <UIView+Position.h>

@interface DetailVC () <UITextFieldDelegate, UITextViewDelegate> {

    IBOutlet UIView *emailModalView;
    IBOutlet UIView *messageModalView;
    
    
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UITextField *emailTextField;
    
    __weak IBOutlet UIButton *barMessageButton;
    __weak IBOutlet UIButton *barApplyButton;
    __weak IBOutlet UIButton *barFriendButton;
    __weak IBOutlet UIButton *barFavouriteButton;
    
    UIImage *mainImage;

    BOOL isFavourite;
    
    UIImage *loveImage;
    UIImage *loveImageSelected;
    
    NSMutableDictionary *data;

    __weak IBOutlet UIScrollView *mainScrollView;
    __weak IBOutlet UIImageView *companyImageView;
    __weak IBOutlet UILabel *companyNameLabel;
    __weak IBOutlet UILabel *positionLabel;
    __weak IBOutlet UITextView *mainTextView;
    __weak IBOutlet UILabel *pricingLabel;
    __weak IBOutlet UILabel *locationLabel;
    
    __weak IBOutlet NSLayoutConstraint *textHeightContraint;
    __weak IBOutlet UIView *messageHolderView;
    
    __weak IBOutlet UIView *emailHolderView;
    
    CGFloat baseTop;
    
    
}

@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadModalViews];
    [barApplyButton addTarget:self action:@selector(showMessageModal) forControlEvents:UIControlEventTouchUpInside];
    [barFavouriteButton addTarget:self action:@selector(markAsFavourite) forControlEvents:UIControlEventTouchUpInside];
    [barFriendButton addTarget:self action:@selector(showFriendModal) forControlEvents:UIControlEventTouchUpInside];
    [barMessageButton addTarget:self action:@selector(openDialog) forControlEvents:UIControlEventTouchUpInside];

    mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, mainScrollView.contentSize.height);
    [mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, mainScrollView.frame.size.height)];
    
    loveImage = [UIImage imageNamed:@"love-tab-icon"];
    loveImageSelected = [UIImage imageNamed:@"glowing-love"];

    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0,-15, -28, 0) : UIEdgeInsetsMake(0, -39, 0, 0)];
    [barFavouriteButton setImageEdgeInsets:UIEdgeInsetsMake(-11, 0, 0, -69)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    [self setupContent];
}

- (void)setupContent {
    NSDictionary *jobInfo = data[@"job"];
    NSDictionary *companyInfo = data[@"company"];
    
    pricingLabel.text = [NSString stringWithFormat:@"Ücret Skalası: %@%@", jobInfo[@"salaryBegin"], jobInfo[@"salaryEnd"] ? [NSString stringWithFormat:@" - %@", jobInfo[@"salaryEnd"]]  : @""];
    
    positionLabel.text = jobInfo[@"position"];
    companyNameLabel.text = companyInfo[@"name"];
    locationLabel.text = companyInfo[@"location"];
    
    mainTextView.text = [NSString stringWithFormat:@"%@\n\n%@", companyInfo[@"info"], jobInfo[@"info"]];
    
    CGFloat textHeight = [mainTextView sizeThatFits:CGSizeMake(mainTextView.frame.size.width, FLT_MAX)].height;
    
    textHeightContraint.constant = textHeight;
    
//    infoTextView.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
    if (mainImage) {
        companyImageView.image = mainImage;
    } else {
        
        companyImageView.image = [UIImage imageNamed:@"company-placeholder"];
    }
}




- (void)updateImage:(UIImage *)image {
    mainImage = image;
    if (image && companyImageView) {
        companyImageView.image = image;
    }
}

- (void)setData:(NSMutableDictionary *)dataDictionary {
    data = dataDictionary;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)markAsFavourite {
    isFavourite = !isFavourite;
    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0, -15, -28, 0) : UIEdgeInsetsMake(0, -40, -28, 0)];
    
}

- (void)showMessageModal {
    messageHolderView.frameY = baseTop;
    [self.navigationController.view addSubview:messageModalView];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
}

- (void)showFriendModal {
    emailHolderView.frameY = baseTop;
    [self.navigationController.view addSubview:emailModalView];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
}

- (void)openDialog {
    [self performSegueWithIdentifier:@"openChat" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openChat"]) {
        ChatVC *chat = segue.destinationViewController;
        chat.fromDetail = YES;
    }
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardStartFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGFloat delta = keyboardEndFrame.origin.y - keyboardStartFrame.origin.y;
//    scrollViewBottomConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;
    
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        messageHolderView.frameY = fabs(delta) > 100 && delta > 0 ? baseTop : 30;
        emailHolderView.frameY = fabs(delta) > 100 && delta > 0 ? baseTop : 30;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)loadModalViews {
    [[NSBundle mainBundle] loadNibNamed:@"ModalView" owner:self options:nil];
    
    emailModalView.frame = [UIScreen mainScreen].bounds;
    messageModalView.frame = [UIScreen mainScreen].bounds;
    
    UITapGestureRecognizer *hide1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideModals)];
    UITapGestureRecognizer *hide2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideModals)];
    
    [emailModalView.subviews[0] addGestureRecognizer:hide1];
    [messageModalView.subviews[0] addGestureRecognizer:hide2];
    
    emailTextField.layer.borderWidth = 0.5;
    emailTextField.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    messageTextView.layer.borderWidth = 0.5;
    messageTextView.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    emailTextField.delegate = self;
    messageTextView.delegate = self;
    baseTop = messageHolderView.frameY;
}

- (void)hideModals {
    [emailModalView removeFromSuperview];
    [messageModalView removeFromSuperview];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelNormal];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0 / 255.0 green:50.0 / 255.0 blue:84.0 / 255.0 alpha:1.0]];
}


- (IBAction)dismissSelf:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
