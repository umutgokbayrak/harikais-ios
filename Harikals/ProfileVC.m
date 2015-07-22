//
//  ProfileVC.m
//  Pods
//
//  Created by Nikolay Tabunchenko on 7/7/15.
//
//

#import "ProfileVC.h"
#import "ProfileCell.h"
#import <UIView+Position.h>
#import "OHActionSheet.h"
#import "HKServer.h"
#import "DropdownModel.h"
#import "FillVC.h"
#import <UIImageView+WebCache.h>

#import <IOSLinkedInAPI/LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>


typedef void (^PFStringResultBlock)(NSString * string, NSError * error);

#define kFIRST_CELL_HEIGHT  50.0
#define kCELL_HEIGHT  67.0

@interface ProfileVC () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DropMenuDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
    
    
    __weak IBOutlet NSLayoutConstraint *scrollBottomSpace;
    
    __weak IBOutlet UIActivityIndicatorView *spinner1;
    __weak IBOutlet UIActivityIndicatorView *spinner2;
    
    
    UITapGestureRecognizer *tap;
    
    __weak IBOutlet NSLayoutConstraint *showingLinkedInConstraint;
    
    __weak IBOutlet NSLayoutConstraint *positionHeight;
    __weak IBOutlet NSLayoutConstraint *eduHeight;
    __weak IBOutlet NSLayoutConstraint *skilsHeight;
    
    __weak IBOutlet UIImageView *avatarImageView;
    
    
    __weak IBOutlet UILabel *aradiLabel;
    
    __weak IBOutlet UITableView *positionTableView;
    __weak IBOutlet UITableView *eduTableView;
    __weak IBOutlet UITableView *skilsTableView;
    
    
    __weak IBOutlet UILabel *liLabel;
    __weak IBOutlet UIButton *liButton;
    NSMutableArray *positionsArray;
    NSMutableArray *edusArray;
    NSMutableArray *skillsArray;
    
    NSMutableDictionary *profileDictionaty;
    
    UIImage *avatarImage;
    NSString *jobFunction;
    
    
    __weak IBOutlet NSLayoutConstraint *dropHeight1;
    __weak IBOutlet NSLayoutConstraint *dropHeight2;
    __weak IBOutlet NSLayoutConstraint *dropHeight3;

    __weak IBOutlet UITableView *dropTable1;
    __weak IBOutlet UITableView *dropTable2;
    __weak IBOutlet UITableView *dropTable3;
    
    NSMutableArray *dropOptions1;
    NSMutableArray *dropOptions2;
    NSMutableArray *dropOptions3;
    
    DropdownModel *model1;
    DropdownModel *model2;
    DropdownModel *model3;

    
    NSString *avatarUrl;
    
    ProfileCell *textInputCell;
    
    BOOL addingSkill;
    
    
    __weak IBOutlet UITextField *firstTextField;
    __weak IBOutlet UITextField *neredeTextField;
    __weak IBOutlet UITextField *thirdTextField;

    __weak IBOutlet UITextField *industryTextField;
    __weak IBOutlet UIScrollView *mainScrollView;
    
    
    
    __weak IBOutlet UILabel *positionCountLabel;
    
    __weak IBOutlet UILabel *educationCountLabel;
    
    
    __weak IBOutlet UIBarButtonItem *leftBarButtonItem;
    __weak IBOutlet UIButton *closeButton;
    
}

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];

    model1 = [[DropdownModel alloc] init];
    model2 = [[DropdownModel alloc] init];
    model3 = [[DropdownModel alloc] init];
    dropTable1.delegate = model1;
    dropTable1.dataSource = model1;
    
    dropTable2.delegate = model2;
    dropTable2.dataSource = model2;

    dropTable3.delegate = model3;
    dropTable3.dataSource = model3;
    
    dropOptions1 = [NSMutableArray array];
    dropOptions2 = [NSMutableArray array];
    dropOptions3 = [NSMutableArray array];
    
    model1.dataArray = dropOptions1;
    model2.dataArray = dropOptions2;
    model3.dataArray = dropOptions3;
    
    model1.delegate = self;
    model2.delegate = self;
    model3.delegate = self;
    
    
    positionsArray = [NSMutableArray array];
    edusArray = [NSMutableArray array];
    skillsArray = [NSMutableArray array];
    
    [self configFetched];
    
    positionTableView.delegate = self;
    eduTableView.delegate = self;
    skilsTableView.delegate = self;
    
    positionTableView.dataSource = self;
    eduTableView.dataSource = self;
    skilsTableView.dataSource = self;
    avatarImageView.layer.cornerRadius = avatarImageView.frameWidth / 2.0;
    avatarImageView.clipsToBounds = YES;

    dropTable1.layer.borderWidth = 0.5;
    dropTable1.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    dropTable2.layer.borderWidth = 0.5;
    dropTable2.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    dropTable3.layer.borderWidth = 0.5;
    dropTable3.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobFunction:) name:@"updateJobFunction" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEdu:) name:@"updateEdu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompany:) name:@"updateCompany" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configFetched) name:@"configFetched" object:nil];

    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    
    [neredeTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    [industryTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    
    textInputCell = [positionTableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
    textInputCell.inTextField.delegate = self;
    [textInputCell.inTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    [self loadFromInputDictionary];
    [self reloadTables];
    [self reloadDropMenu];

    [spinner1 stopAnimating];
    [spinner2 stopAnimating];
    [textInputCell.spinner stopAnimating];
    
    
    if (self.inputDictionary) {
        [closeButton setTitle:@"Vazgeç" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeWithoutSaving) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [Server callFunctionInBackground:@"info" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary * object, NSError *error) {
        if (object) {

            [self updateAvatarWithUrl:object[@"pictureUrl"]];
            [[NSUserDefaults standardUserDefaults] setObject:object[@"pictureUrl"] forKey:@"imageUrl"];
        }
        
    }];
    
}

- (void)configFetched {
    if (Server.configDictionary) {
        if (![Server.configDictionary[@"linkedin"][@"enabled"] isEqualToNumber:@1]) {
            [self hideLIButton];
        }
    }
}

- (void)updateAvatarWithUrl:(NSString *)urlString {
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        avatarImage = image;
    }];
}

- (void)loadFromInputDictionary {
    if (_inputAvatar) {
        avatarImageView.image = _inputAvatar;
    }
    if (self.inputDictionary) {
        NSArray *inputEducation = self.inputDictionary[@"education"];
        if (inputEducation) {
            [edusArray addObjectsFromArray:inputEducation];
        }
        
        NSArray *inputExp = self.inputDictionary[@"experience"];
        if (inputExp) {
            [positionsArray addObjectsFromArray:inputExp];
        }

        NSArray *inputSkills = self.inputDictionary[@"skills"];
        if (inputSkills) {
            [skillsArray addObjectsFromArray:inputSkills];
        }
        
        firstTextField.text = self.inputDictionary[@"fullname"];
        industryTextField.text = self.inputDictionary[@"industry"];
        neredeTextField.text = self.inputDictionary[@"location"];
        thirdTextField.text = self.inputDictionary[@"headline"];
        if (self.inputDictionary[@"functionality"]) {
            aradiLabel.text = self.inputDictionary[@"functionality"];
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    if (self.inputDictionary) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0 / 255.0 green:50.0 / 255.0 blue:84.0 / 255.0 alpha:1.0]];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)hideLIButton {
    showingLinkedInConstraint.constant = 17;
    liLabel.hidden = YES;
    liButton.hidden = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textInputCell.inTextField != textField && textField != industryTextField) {
        [mainScrollView setContentOffset:CGPointMake(0, textField.frameY + 50) animated:YES];
    } else if (textField == industryTextField) {
        [mainScrollView setContentOffset:CGPointMake(0, textField.superview.frameY - 40) animated:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    addingSkill = NO;
    [self reloadTables];
    [self hideKeyboard];

    return NO;
}

- (void)hideKeyboard {
    [dropOptions1 removeAllObjects];
    [dropOptions2 removeAllObjects];
    [dropOptions3 removeAllObjects];
    [self reloadDropMenu];
    [self.view endEditing:YES];
}

- (void)didSelectOption:(NSString *)optionString optionsArray:(NSMutableArray *)array {
    [array removeAllObjects];
    if (array == dropOptions1) {
        neredeTextField.text = optionString;
    } else if (array == dropOptions2) {
        industryTextField.text = optionString;
    } else if (array == dropOptions3) {
        [skillsArray addObject:optionString];
        [skilsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        industryTextField.text = @"";
    }
    [self.view endEditing:YES];
    [self adjustHightsAnimated:YES];
    [self reloadDropMenu];
}

- (void)refreshTOkens {
    [(LIALinkedInHttpClient *)Server.linkedInHttpClient getAuthorizationCode:^(NSString *authorizationCode) {
        [(LIALinkedInHttpClient *)Server.linkedInHttpClient getAccessToken:authorizationCode success:^(NSDictionary *accessTokenDictionary) {
            [[NSUserDefaults standardUserDefaults] setObject:accessTokenDictionary forKey:@"temporary"];
            [Server getProfileIDWithAccessToken:accessTokenDictionary[@"access_token"] block:^(NSString *object, NSError *error) {
                
                if (!error && object) {
                    [self processLIData:(NSDictionary *)object];
                } else {
                    
                }
            }];
            
        } failure:^(NSError *accessTokenError) {
            
        }];
    } cancel:^{
        [self showAlertWithText:@"Arzu ederseniz bu ekranda profilinizi kendiniz de yarata-bilirsiniz"];
    } failure:^(NSError *authorizationCodeError) {
        
    }];
}

- (IBAction)connectLinkedIn:(id)sender {

    [Server getProfileIDWithAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"temporary"][@"access_token"] block:^(NSString *object, NSError *error) {
        if (!error && object) {
            [self processLIData:(NSDictionary *)object];
        } else {
            [self refreshTOkens];
        }
    }];
}

- (void)processLIData:(NSDictionary *)responceDict {
    firstTextField.text = [NSString stringWithFormat:@"%@ %@", responceDict[@"firstName"], responceDict[@"lastName"]];
    thirdTextField.text = responceDict[@"headline"];
    
    if (responceDict[@"industry"]) {
        industryTextField.text = responceDict[@"industry"];
    }

    if (responceDict[@"location"] && responceDict[@"location"][@"name"]) {
        neredeTextField.text = responceDict[@"location"][@"name"];
    }

}

- (void)showAlertWithText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (void)reloadTables {
    [positionTableView reloadData];
    [eduTableView reloadData];
    [skilsTableView reloadData];
//    positionHeight.constant = kCELL_HEIGHT * (positionsArray.count) + kFIRST_CELL_HEIGHT - 2;
//    eduHeight.constant = kCELL_HEIGHT * (edusArray.count) + kFIRST_CELL_HEIGHT - 2;
//    skilsHeight.constant = kCELL_HEIGHT * (skillsArray.count) + kFIRST_CELL_HEIGHT - 2;
    [self adjustHightsAnimated:NO];
}

- (void)adjustHightsAnimated:(BOOL)animated {

    positionHeight.constant = kCELL_HEIGHT * (positionsArray.count) + kFIRST_CELL_HEIGHT - 2;
    eduHeight.constant = kCELL_HEIGHT * (edusArray.count) + kFIRST_CELL_HEIGHT - 2;
    skilsHeight.constant = kFIRST_CELL_HEIGHT * (skillsArray.count) + kFIRST_CELL_HEIGHT - 2;
    
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    
}


- (void)textFieldDidChange:(UITextField *)textField {
    NSMutableArray *options;
    if ([textField isEqual:neredeTextField]) {
     
        options = dropOptions1;
    } else if ([textField isEqual:industryTextField]) {

        options = dropOptions2;
    } else if ([textField isEqual:textInputCell.inTextField]) {
        options = dropOptions3;
    }

    [self auticompleteWithText:textField.text optionsArray:options field:textField];
    

}

- (void)closeWithoutSaving {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)auticompleteWithText:(NSString *)text optionsArray:(NSMutableArray *)options field:(UITextField *)field{
    NSString *function;
    if (options == dropOptions1) {
        function = @"autocompleteLocation";
        if (!spinner1.isAnimating)
        [spinner1 startAnimating];
    } else if (options == dropOptions2) {
        function = @"autocompleteIndustries";
        if (!spinner2.isAnimating)
        [spinner2 startAnimating];
    } else if (options == dropOptions3) {
        function = @"autocompleteSkills";
        if (!textInputCell.spinner.isAnimating)
        [textInputCell.spinner startAnimating];
    }
    NSString *savedtext = [text copy];
    if (!text.length) {
        [options removeAllObjects];
        [spinner1 stopAnimating];
        [spinner2 stopAnimating];
        [textInputCell.spinner stopAnimating];
        [self reloadDropMenu];
    } else {
        [Server callFunctionInBackground:function withParameters:@{@"str" : savedtext} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                [options removeAllObjects];
                if ([savedtext isEqualToString:field.text]) {
                    [options addObjectsFromArray:receivedItems];
                }
                [self reloadDropMenu];
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            [spinner1 stopAnimating];
            [spinner2 stopAnimating];
            [textInputCell.spinner stopAnimating];
        }];
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == textInputCell.inTextField) {
        if (!textField.isFirstResponder) {
            addingSkill = NO;
            skilsHeight.constant = kFIRST_CELL_HEIGHT - 2;
            [skilsTableView reloadData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [Server.firstNavVC setNavigationBarHidden:YES animated:NO];
}

- (IBAction)save:(id)sender {
    NSString *cuttedName = [firstTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (!firstTextField.text.length || cuttedName.length < 3) {[self showErrorAlert:@"Lütfen adınız ve soyadınızı bizimle paylaşır mısınız?"] ;return;}
    
    NSString *cuttedNerede = [neredeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!neredeTextField.text.length || cuttedNerede.length < 3) {[self showErrorAlert:@"Lütfen nerede yaşadığınızı bizimle paylaşır mısınız?"] ;return;}
    
    NSString *cuttedthird = [thirdTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!thirdTextField.text.length  || cuttedthird.length < 2) {[self showErrorAlert:@"Lütfen mesleki ünvanınızı bizimle paylaşır mısınız?"] ;return;}
    
    
    if (!aradiLabel.text.length) {[self showErrorAlert:@"Lütfen kendinize çalışmak istediğiniz bir fonksiyon seçer misiniz?"] ;return;}

    
    if (!industryTextField.text.length) {[self showErrorAlert:@"Lütfen kendinize çalışmak istediğiniz bir endüstri seçer misiniz?"]; return;}

    
    if (!positionsArray.count) {[self showErrorAlert:@"Lütfen mesleki deneyiminizi bizimle paylaşır mısınız?"]; return;}
    if (!edusArray.count) {[self showErrorAlert:@"Lütfen geçmiş eğitim bilgilerinizi bizimle paylaşır mısınız?"]; return;}
    
    if (skillsArray.count < 3) {[self showErrorAlert:@"Lütfen uzman olduğunuzu düşündüğünüz becerilerden en az 3 tane bizimle pay- laşır mısınız?"]; return;}
    
    
    NSMutableDictionary *params = [@{@"userId" : Server.userInfoDictionary[@"userId"],
                             @"fullname" : firstTextField.text,
                             @"location" : neredeTextField.text,
                             @"functionality" : aradiLabel.text,
                             @"industry" : industryTextField.text,
                             @"headline" : thirdTextField.text,
                             @"experience" : positionsArray,
                             @"education" : edusArray,
                             @"skills" : skillsArray,
                             } mutableCopy];
    NSString *pictureUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageUrl"];
    if (pictureUrl) {
        [params setObject:pictureUrl forKey:@"avatarUrl"];
    }
    
    [Server callFunctionInBackground:@"saveCv" withParameters:params block:^(NSDictionary *receivedItems, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:@{@"fullname" : params[@"fullname"], @"headline" : params[@"headline"]} forKey:@"personal"];
        if (receivedItems) {
            if (!_inputDictionary) {
                [self performSegueWithIdentifier:@"openMenu" sender:nil];
            } else {
                [self closeWithoutSaving];
            }
        } else {
            [self showAlertWithText:error.description];
            NSLog(@"%@", error);
        }
    }];
    
    
    if (self.inputDictionary) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)showErrorAlert:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}


- (void)reloadDropMenu {
    [dropTable1 reloadData];
    [dropTable2 reloadData];
    [dropTable3 reloadData];
    
    dropHeight1.constant = 35 * dropOptions1.count;
    dropTable1.hidden = !dropOptions1.count;
    
    dropHeight2.constant = MIN(35 * dropOptions2.count, 35 * 4 + 10);
    dropTable2.scrollEnabled = dropHeight2.constant == 35 * 4 + 10;
    dropTable2.hidden = !dropOptions2.count;
 

    dropHeight3.constant = MIN(35 * dropOptions3.count, 35 * 4 + 10);
    dropTable3.scrollEnabled = dropHeight3.constant == 35 * 4 + 10;
    dropTable3.hidden = !dropOptions3.count;
}


- (void)updateJobFunction:(NSNotification *)notification {
    jobFunction = notification.object;
    aradiLabel.text = jobFunction;
    aradiLabel.textColor = [UIColor blackColor];
}

- (void)updateEdu:(NSNotification *)notification {
    
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    
    if (index) {

        [edusArray replaceObjectAtIndex:index - 1 withObject:notification.object];
    } else {
        [edusArray addObject:notification.object];
    }
    
    [self reloadTables];
}

- (void)updateCompany:(NSNotification *)notification {
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    if (index) {

        [positionsArray replaceObjectAtIndex:index - 1 withObject:notification.object];
    } else {
        [positionsArray addObject:notification.object];
    }

    [self reloadTables];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)sender {
    if ([segue.identifier isEqualToString:@"eduPush"]) {
        FillVC *dest = segue.destinationViewController;
        dest.receivedData = [sender[@"data"] count] ? sender[@"data"] : nil;
        dest.index = [sender[@"index"] integerValue];
    } else if ([segue.identifier isEqualToString:@"expPush"]) {
        FillVC *dest = segue.destinationViewController;
        dest.receivedData = [sender[@"data"] count] ? sender[@"data"] : nil;
        dest.index = [sender[@"index"] integerValue];
    }
}

- (IBAction)pickAvatar:(id)sender {
    [OHActionSheet showFromView:self.view title:@"Fotoğraf Ekle" cancelButtonTitle:@"TAMAM" destructiveButtonTitle:nil otherButtonTitles:@[@"Yeni fotoğraf çek", @"Galeriden Seç"] completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {

         NSLog(@"button tapped: %d",buttonIndex);
         if (buttonIndex == sheet.cancelButtonIndex) {
//             self.status.text = @"Your order has been postponed";
         } else if (buttonIndex == sheet.destructiveButtonIndex) {
//             self.status.text = @"Your order has been cancelled";
         } else {
             NSNumber *number = [@[@1, @0] objectAtIndex:(buttonIndex-sheet.firstOtherButtonIndex)];
             [self getPhotoFromCamera:[number boolValue]];
         }
     }];
    
    
}

- (void)getPhotoFromCamera:(BOOL)isCamera {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    

    picker.sourceType = isCamera ?UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    avatarImageView.layer.cornerRadius = avatarImageView.frameWidth /  2.0;
    avatarImageView.clipsToBounds = YES;
    avatarImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    avatarImage = [self formatedImage:avatarImageView.image];
    if (avatarImage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userAvatarPicked" object:avatarImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![[info objectForKey:@"UIImagePickerControllerOriginalImage"] isEqual:_inputAvatar]) {
            if (avatarImage) {
                [Server serverUploadPicture:avatarImage userId:Server.userInfoDictionary[@"userId"] success:^(NSDictionary *responseObject) {
                    
                } failure:^(NSError *error) {
                    
                }];
            }
        }
    }];
}

- (UIImage *)formatedImage:(UIImage *)image {
    return image;
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    scrollBottomSpace.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;
    
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (textInputCell.inTextField.isFirstResponder) {
            [mainScrollView setContentOffset:CGPointMake(0, dropTable3.frameY - 100)];
        }
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}


//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:positionTableView]) {
        return positionsArray.count + 1;
    } else if ([tableView isEqual:eduTableView]) {
        return edusArray.count + 1;
    } else if ([tableView isEqual:skilsTableView]) {
        return skillsArray.count + 1 + addingSkill;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) return kFIRST_CELL_HEIGHT;
    if (tableView == skilsTableView) {
        return kFIRST_CELL_HEIGHT;
    }
    return kCELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell;
    if ([tableView isEqual:positionTableView]) {
        cell = [self cellForPositionsRowAtIndexPath:indexPath];
    } else if ([tableView isEqual:eduTableView]) {
        cell = [self cellForEdusRowAtIndexPath:indexPath];
    } else if ([tableView isEqual:skilsTableView]) {
        cell = [self cellForSkillsRowAtIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView isEqual:positionTableView]) {
        NSDictionary *senderArray = @{};
        if (indexPath.row) {
            senderArray = positionsArray[indexPath.row - 1];
        }
        [self performSegueWithIdentifier:@"expPush" sender:@{@"data" : senderArray, @"index" : @(indexPath.row)}];
    } else if ([tableView isEqual:eduTableView]) {
        NSDictionary *senderArray = @{};
        if (indexPath.row) {
            senderArray = edusArray[indexPath.row - 1];
        }
        [self performSegueWithIdentifier:@"eduPush" sender:@{@"data" : senderArray, @"index" : @(indexPath.row)}];
    } else {
        if (!indexPath.row) {
            if (!addingSkill) {
                addingSkill = YES;
                skilsHeight.constant = kFIRST_CELL_HEIGHT + kFIRST_CELL_HEIGHT + kFIRST_CELL_HEIGHT * skillsArray.count - 2;
            } else {
                [dropOptions3 removeAllObjects];
                
                [self reloadDropMenu];
            }
            [skilsTableView reloadData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [textInputCell.inTextField becomeFirstResponder];
                textInputCell.inTextField.text = @"";
            });
        }
    }
}

- (ProfileCell *)cellForPositionsRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell;
    if (!indexPath.row) {
        cell = [positionTableView dequeueReusableCellWithIdentifier:@"greenCell"];
        cell.greenTitleLabel.text = @"Deneyim Ekle";
        
    } else {
        cell = [positionTableView dequeueReusableCellWithIdentifier:@"infoCell"];
        cell.nameLabel.text = positionsArray[indexPath.row - 1][@"title"];
        cell.subLabel.text = positionsArray[indexPath.row - 1][@"name"];
    }
    return cell;
}

- (ProfileCell *)cellForEdusRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell;
    if (!indexPath.row) {
        cell = [positionTableView dequeueReusableCellWithIdentifier:@"greenCell"];
        cell.greenTitleLabel.text = @"Eğitim Ekle";
    } else {
        cell = [positionTableView dequeueReusableCellWithIdentifier:@"infoCell"];
        cell.nameLabel.text = edusArray[indexPath.row - 1][@"school"];
        cell.subLabel.text = edusArray[indexPath.row - 1][@"degree"];
    }
    return cell;
}

- (ProfileCell *)cellForSkillsRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell;
    if (!indexPath.row) {
        cell = [positionTableView dequeueReusableCellWithIdentifier:@"greenCell"];
        cell.greenTitleLabel.text = @"Beceri Ekle";
    } else {
        if (addingSkill) {
            if (indexPath.row == 1) {
                cell = textInputCell;
            } else {
                cell = [positionTableView dequeueReusableCellWithIdentifier:@"skillCell"];
            }
        } else {
            cell = [positionTableView dequeueReusableCellWithIdentifier:@"skillCell"];
        }
        
        if (skillsArray.count) {
            if (cell == textInputCell) return cell;
            cell.nameLabel.text = skillsArray[indexPath.row - 1 - addingSkill];
        }
    }
    return cell;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (eduTableView == tableView || tableView == positionTableView) {
        if (indexPath.row) {
            return YES;
        }
    } else if (skilsTableView == tableView) {
        if (indexPath.row + addingSkill) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (eduTableView == tableView || tableView == positionTableView) {
        if (indexPath.row) {
            return @"   SİL         ";
        }
    } else if (skilsTableView == tableView) {
        if (indexPath.row + addingSkill) {
            return @"   SİL         ";
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) return;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == eduTableView) {
            [edusArray removeObjectAtIndex:indexPath.row - 1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (tableView == positionTableView) {
            [positionsArray removeObjectAtIndex:indexPath.row - 1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (tableView == skilsTableView) {
            [skillsArray removeObjectAtIndex:indexPath.row - 1 - addingSkill];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self adjustHightsAnimated:YES];
    }
}

@end

