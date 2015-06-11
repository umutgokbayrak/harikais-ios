//
//  DetailVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/11/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "DetailVC.h"
#import "ChatVC.h"


@interface DetailVC () {


    IBOutlet UIView *emailModalView;
    IBOutlet UIView *messageModalView;
    
    
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UITextField *emailTextField;
    
    __weak IBOutlet UIButton *barMessageButton;
    __weak IBOutlet UIButton *barApplyButton;
    __weak IBOutlet UIButton *barFriendButton;
    __weak IBOutlet UIButton *barFavouriteButton;
    
    BOOL isFavourite;
    
    UIImage *loveImage;
    UIImage *loveImageSelected;
    
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
    
    loveImage = [UIImage imageNamed:@"love-tab-icon"];
    loveImageSelected = [UIImage imageNamed:@"glowing-love"];

    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0,-15, -28, 0) : UIEdgeInsetsMake(0, -39, 0, 0)];
    [barFavouriteButton setImageEdgeInsets:UIEdgeInsetsMake(-11, 0, 0, -69)];
}

- (void)markAsFavourite {
    isFavourite = !isFavourite;
    [barFavouriteButton setImage:isFavourite ? loveImageSelected : loveImage forState:UIControlStateNormal];
    [barFavouriteButton setTitleEdgeInsets:!isFavourite ? UIEdgeInsetsMake(0, -15, -28, 0) : UIEdgeInsetsMake(0, -40, -28, 0)];
}

- (void)showMessageModal {
    [self.navigationController.view addSubview:messageModalView];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
}

- (void)showFriendModal {
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


- (void)loadModalViews {
    [[NSBundle mainBundle] loadNibNamed:@"ModalView" owner:self options:nil];
    
    UITapGestureRecognizer *hide1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideModals)];
    UITapGestureRecognizer *hide2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideModals)];
    
    [emailModalView.subviews[0] addGestureRecognizer:hide1];
    [messageModalView.subviews[0] addGestureRecognizer:hide2];
    
    emailTextField.layer.borderWidth = 0.5;
    emailTextField.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    messageTextView.layer.borderWidth = 0.5;
    messageTextView.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
}

- (void)hideModals {
    [emailModalView removeFromSuperview];
    [messageModalView removeFromSuperview];
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71.0 / 255.0 green:160.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]];
}


- (IBAction)dismissSelf:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
