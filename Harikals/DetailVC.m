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
#import "HKServer.h"
#import <Parse.h>

@interface DetailVC () <UITextFieldDelegate, UITextViewDelegate, UIWebViewDelegate> {

    IBOutlet UIView *emailModalView;
    IBOutlet UIView *messageModalView;
    
    __weak IBOutlet UIWebView *contenWebView;
    
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UITextField *emailTextField;
    
    __weak IBOutlet UIButton *barMessageButton;
    __weak IBOutlet UIButton *barApplyButton;
    __weak IBOutlet UIButton *barFriendButton;
    __weak IBOutlet UIButton *barFavouriteButton;
    
    __weak IBOutlet UIImageView *moneyBagIcon;
    UIImage *mainImage;

    BOOL isFavourite;
    BOOL isApplied;
    
    
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
    
    __weak IBOutlet UIButton *referFriendButton;
    
    __weak IBOutlet UILabel *messagePlaceholderLabel;
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

        
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    isFavourite = [data[@"flags"][@"favorited"] boolValue];
    isApplied = [data[@"flags"][@"applied"] boolValue];
    if (isApplied) {
        [self setApplicationButtonDisabled];
    }
    
    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitle:isFavourite ? @"Favori Sil" : @"Favori Ekle" forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0, -15, -28, 0) : UIEdgeInsetsMake(0, -40, -28, 0)];
    [barFavouriteButton setImageEdgeInsets:!isFavourite ? UIEdgeInsetsMake(-10, 0, 0, -63) : UIEdgeInsetsMake(-11, 0, 0, -53)];
    
    [self setupContent];
}

- (void)setupContent {
    NSDictionary *jobInfo = data[@"job"];
    NSDictionary *companyInfo = data[@"company"];
    
    
    NSString *resultSalary = @"";
    
    NSString *minSalary = jobInfo[@"salaryBegin"];
    NSString *maxSalary = jobInfo[@"salaryEnd"];
    
    if (minSalary.integerValue == 0 && maxSalary.integerValue != 0) {
        resultSalary = [NSString stringWithFormat:@"Ücret Skalası: %@ TL'ye kadar", maxSalary];
    } else if (minSalary.integerValue != 0 && maxSalary.integerValue == 0) {
        resultSalary = [NSString stringWithFormat:@"Ücret Skalası: %@ TL'den fazla", minSalary];
    } else if (minSalary.integerValue == 0 && maxSalary.integerValue == 0) {
        pricingLabel.text = resultSalary;
        moneyBagIcon.hidden = YES;
    } else {
        pricingLabel.text = [NSString stringWithFormat:@"Ücret Skalası: %@%@", jobInfo[@"salaryBegin"], jobInfo[@"salaryEnd"] ? [NSString stringWithFormat:@" - %@", jobInfo[@"salaryEnd"]]  : @""];
    }



    positionLabel.text = jobInfo[@"position"];
    companyNameLabel.text = companyInfo[@"name"];
    locationLabel.text = companyInfo[@"location"];
    mainTextView.hidden = YES;
    mainTextView.text = [NSString stringWithFormat:@"%@\n\n%@", companyInfo[@"info"], jobInfo[@"info"]];
    
    CGFloat textHeight = [mainTextView sizeThatFits:CGSizeMake(mainTextView.frame.size.width, FLT_MAX)].height;
    
    textHeightContraint.constant = textHeight;
    
//    infoTextView.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
    if (mainImage) {
        companyImageView.image = mainImage;
    } else {
        
        companyImageView.image = [UIImage imageNamed:@"company-placeholder"];
    }
    [self configureText:companyInfo[@"info"] secondText:jobInfo[@"info"]];
}

- (void)configureText:(NSString *)companyText  secondText:(NSString *)secondText {
    NSString *firstHeader = @"<tag>Firma Hakkında:</tag><br>";
    NSString *secondHeader = @"<tag>İş Hakkında:</tag><br>";
    if ([[secondText substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"<p>"]) {
        secondText = [secondText substringWithRange:NSMakeRange(3, secondText.length - 3)];
        secondHeader = [NSString stringWithFormat:@"<p>%@", secondHeader];
    } else {
        secondHeader = @"<tag>İş Hakkında:</tag><br>";
    }
    
    NSString *resultString = [NSString stringWithFormat:@"%@%@%@%@", firstHeader, companyText, secondHeader, secondText];
    
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   
                                   "body {font-family: \"%@\"; font-size: %@;}\n"
                                   "tag {font-family: \"OpenSans-Semibold\"; font-size: 13.0;}\n"
                                   
                                   "</style> \n"
                                   "</head> \n"
                                   
                                   
                                   "<body>%@</body> \n"
                                   "</html>", @"OpenSans-Light", @14, resultString];

    [contenWebView loadHTMLString:myDescriptionHTML baseURL:nil];
    contenWebView.delegate = self;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    textHeightContraint.constant = contenWebView.scrollView.contentSize.height;
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

- (void)setApplicationButtonDisabled {
    barApplyButton.backgroundColor = [UIColor colorWithRed:196.0 / 255.0 green:196.0 / 255.0 blue:196.0 / 255.0 alpha:1.0];
    barApplyButton.userInteractionEnabled = NO;
    [barApplyButton setTitle:@"Başvuruldu" forState:UIControlStateNormal];
    [barApplyButton setImageEdgeInsets:UIEdgeInsetsMake(-11, 0, 0, -63)];
    isApplied = YES;
}

- (IBAction)applyToJob:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    NSString *message = messageTextView.text;
    [self hideModals];
    NSDictionary *params  = @{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"id"], @"message" : message};
    [Server callFunctionInBackground:@"applyToJob" withParameters:params block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems) {
            [self setApplicationButtonDisabled];
            [Server showFavouriteAlertWithTitle:@"İşlem Tamam" text:@"Pozisyon için başvurunuz insan kaynaklarına iletilmiştir. Başvurunuzun durumunu ana menüden erişilen Başvurular adımından izleyebilirsiniz."];
            [self updateFlags];
            [Server sendEventNamed:@"Apply to job"];
        } else {
            sender.userInteractionEnabled = YES;
            //TODO:Remove NSLog
            NSLog(@"%@", error);
        }

    }];
}

- (IBAction)referFriend:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    NSString *message = emailTextField.text;
    if ([self validateEmail:message]) {
        [self hideModals];
        NSDictionary *params = @{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"id"], @"friend" : message};
        [Server callFunctionInBackground:@"referFriend" withParameters:params block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {

                [Server showFavouriteAlertWithTitle:@"İşlem Başarılı" text:@"Arkadaşınız bu fırsattan haberdar edildi. Desteğiniz için teşekkür ederiz"];
                [Server sendEventNamed:@"Friend recomended"];
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            sender.userInteractionEnabled = YES;
        }];
    } else {
        sender.userInteractionEnabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen arkadaşınızın eposta adresini kontrol ediniz" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    }
}

- (BOOL)validateEmail:(NSString *)tempMail {
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:tempMail];
}

- (void)updateFlags {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFlags" object:@{@"favorited" : @(isFavourite), @"applied" : @(isApplied)} userInfo:@{@"id" : data[@"id"]}];
}

- (void)markAsFavourite {
    isFavourite = !isFavourite;
    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitle:isFavourite ? @"Favori Sil" : @"Favori Ekle" forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0, -15, -28, 0) : UIEdgeInsetsMake(0, -40, -28, 0)];
    [barFavouriteButton setImageEdgeInsets:!isFavourite ? UIEdgeInsetsMake(-10, 0, 0, -63) : UIEdgeInsetsMake(-11, 0, 0, -53)];
    barFavouriteButton.userInteractionEnabled = NO;
    if (isFavourite) {
        [Server callFunctionInBackground:@"addFavorite" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"id"]                                                                           } block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                [Server showFavouriteAlertWithTitle:@"İşlem tamam" text:@"Fırsat favorileriniz arasına eklenmiştir."];
                
                [self updateFlags];
                [Server sendEventNamed:@"Added to favorites"];
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            barFavouriteButton.userInteractionEnabled = YES;
                                                                           }];
    } else {
        [Server callFunctionInBackground:@"removeFavorite" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"id"]} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                [self updateFlags];
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            barFavouriteButton.userInteractionEnabled = YES;
        }];
    }
    
}

- (void)showMessageModal {
    messageHolderView.frameY = baseTop;
    messagePlaceholderLabel.frame = messageTextView.frame;
    messagePlaceholderLabel.frameX += 4;
    messagePlaceholderLabel.hidden = NO;
    messageTextView.text = @"";
    [self.navigationController.view addSubview:messageModalView];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
}

- (void)showFriendModal {
    emailHolderView.frameY = baseTop;
    emailTextField.text = @"";
    [referFriendButton setBackgroundColor:[UIColor colorWithRed:237.0 / 255.0 green:113.0 / 255.0 blue:97.0 / 255.0 alpha:1.0]];
    [self.navigationController.view addSubview:emailModalView];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
}

- (void)openDialog {
    [Server sendEventNamed:@"Chat started"];
    [self performSegueWithIdentifier:@"openChat" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openChat"]) {
        ChatVC *chat = segue.destinationViewController;
        chat.dataDictionary = data;
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
    messagePlaceholderLabel.hidden = textView.text.length;
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
    
    [emailTextField addTarget:self action:@selector(emailChanged:) forControlEvents:UIControlEventEditingChanged];
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
    self.screenName = @"DetailVC";
}

- (void)emailChanged:(UITextField *)textField {
    [referFriendButton setBackgroundColor:[self validateEmail:textField.text] ? [UIColor colorWithRed:237.0 / 255.0 green:113.0 / 255.0 blue:97.0 / 255.0 alpha:1.0] :[UIColor colorWithRed:196.0 / 255.0 green:196.0 / 255.0 blue:196.0 / 255.0 alpha:1.0] ];
}


- (IBAction)dismissSelf:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
