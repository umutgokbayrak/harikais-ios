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


#import <IOSLinkedInAPI/LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>


typedef void (^PFStringResultBlock)(NSString * string, NSError * error);

#define kFIRST_CELL_HEIGHT  50.0
#define kCELL_HEIGHT  67.0

@interface ProfileVC () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DropMenuDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
    
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

    __weak IBOutlet UITableView *dropTable1;
    __weak IBOutlet UITableView *dropTable2;
    
    NSMutableArray *dropOptions1;
    NSMutableArray *dropOptions2;
    
    DropdownModel *model1;
    DropdownModel *model2;
    
    __weak IBOutlet UITextField *neredeTextField;
    __weak IBOutlet UITextField *industryTextField;
    
    
    
}

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model1 = [[DropdownModel alloc] init];
    model2 = [[DropdownModel alloc] init];
    dropTable1.delegate = model1;
    dropTable1.dataSource = model1;

    dropTable2.delegate = model2;
    dropTable2.dataSource = model2;

    dropOptions1 = [NSMutableArray array];
    dropOptions2 = [NSMutableArray array];
    
    model1.dataArray = dropOptions1;
    model2.dataArray = dropOptions2;
    
    model1.delegate = self;
    model2.delegate = self;
    
    
    positionsArray = [NSMutableArray array];
    edusArray = [NSMutableArray array];
    skillsArray = [NSMutableArray array];
    
    
    positionTableView.delegate = self;
    eduTableView.delegate = self;
    skilsTableView.delegate = self;
    
    positionTableView.dataSource = self;
    eduTableView.dataSource = self;
    skilsTableView.dataSource = self;
    

    dropTable1.layer.borderWidth = 0.5;
    dropTable1.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    dropTable2.layer.borderWidth = 0.5;
    dropTable2.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobFunction:) name:@"updateJobFunction" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEdu:) name:@"updateEdu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompany:) name:@"updateCompany" object:nil];
    
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    
    [neredeTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    [industryTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    [self reloadTables];
    [self reloadDropMenu];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)hideLIButton {
    showingLinkedInConstraint.constant = 17;
    liLabel.hidden = YES;
    liButton.hidden = YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard];
    
    return NO;
}

- (void)hideKeyboard {
    [dropOptions1 removeAllObjects];
    [dropOptions2 removeAllObjects];
    [self reloadDropMenu];
    [self.view endEditing:YES];
}

- (void)didSelectOption:(NSString *)optionString optionsArray:(NSMutableArray *)array {
    [array removeAllObjects];
    if (array == dropOptions1) {
        neredeTextField.text = optionString;
    } else if (array == dropOptions2) {
        industryTextField.text = optionString;
    }
    [self.view endEditing:YES];
    [self reloadDropMenu];
}

- (IBAction)connectLinkedIn:(id)sender {
    [(LIALinkedInHttpClient *)Server.linkedInHttpClient getAuthorizationCode:^(NSString *authorizationCode) {
        [(LIALinkedInHttpClient *)Server.linkedInHttpClient getAccessToken:authorizationCode success:^(NSDictionary *accessTokenDictionary) {

        } failure:^(NSError *accessTokenError) {

        }];
    } cancel:^{

    } failure:^(NSError *authorizationCodeError) {

    }];
    
}




- (void)reloadTables {
    positionHeight.constant = kCELL_HEIGHT * (positionsArray.count) + kFIRST_CELL_HEIGHT - 2;
    eduHeight.constant = kCELL_HEIGHT * (edusArray.count) + kFIRST_CELL_HEIGHT - 2;
    skilsHeight.constant = kCELL_HEIGHT * (skillsArray.count) + kFIRST_CELL_HEIGHT - 2;

}

- (void)textFieldDidChange:(UITextField *)textField {
    NSMutableArray *options;
    if ([textField isEqual:neredeTextField]) {
     
        options = dropOptions1;
    } else if ([textField isEqual:industryTextField]) {

        options = dropOptions2;
    }

    [self auticompleteWithText:textField.text optionsArray:options field:textField];
    

}


- (void)auticompleteWithText:(NSString *)text optionsArray:(NSMutableArray *)options field:(UITextField *)field{
    NSString *function;
    if (options == dropOptions1) {
        function = @"autocompleteLocation";
    } else if (options == dropOptions2) {
        function = @"autocompleteIndustries";
    }
    NSString *savedtext = [text copy];
    if (!text.length) {
        [options removeAllObjects];
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
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [Server.firstNavVC setNavigationBarHidden:YES animated:NO];
}

- (IBAction)save:(id)sender {
    [Server callFunctionInBackground:@"info" withParameters:@{@"userId" : @"123"} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems) {
            
            
            Server.userInfoDictionary = receivedItems;
//            [self.navigationController setNavigationBarHidden:YES animated:NO];
//            [Server.firstNavVC setNavigationBarHidden:YES animated:NO];
            [self performSegueWithIdentifier:@"openMenu" sender:nil];

        } else {
            //TODO:Remove NSLog
            NSLog(@"%@", error);
        }
    }];
    

}


- (void)reloadDropMenu {
    [dropTable1 reloadData];
    [dropTable2 reloadData];
    
    dropHeight1.constant = 35 * dropOptions1.count;
    dropTable1.hidden = !dropOptions1.count;
    
    dropHeight2.constant = MIN(35 * dropOptions2.count, 35 * 4 + 10);
    dropTable2.scrollEnabled = dropHeight2.constant = 35 * 4 + 10;
    dropTable2.hidden = !dropOptions2.count;
 
}


- (void)updateJobFunction:(NSNotification *)notification {
    jobFunction = notification.object;
}

- (void)updateEdu:(NSNotification *)notification {
    [edusArray addObject:notification.object];
    [self reloadTables];
}

- (void)updateCompany:(NSNotification *)notification {
    [positionsArray addObject:notification.object];
    [self reloadTables];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"eduPush"]) {
        FillVC *dest = segue.destinationViewController;
        dest.receivedData = sender;
    } else if ([segue.identifier isEqualToString:@"expPush"]) {
        FillVC *dest = segue.destinationViewController;
        dest.receivedData = sender;
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    avatarImageView.layer.cornerRadius = avatarImageView.frameWidth /  2.0;
    avatarImageView.clipsToBounds = YES;
    avatarImageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    avatarImage = [self formatedImage:avatarImageView.image];

    if (avatarImage) {
        [Server serverUploadPicture:avatarImage userId:@"1234" success:^(NSDictionary *responseObject) {
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (UIImage *)formatedImage:(UIImage *)image {
    return image;
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
        return skillsArray.count + 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) return kFIRST_CELL_HEIGHT;
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
        NSArray *senderArray;
        if (indexPath.row) {
            senderArray = positionsArray[indexPath.row - 1];
        }
        [self performSegueWithIdentifier:@"expPush" sender:senderArray];
    } else if ([tableView isEqual:eduTableView]) {
        NSArray *senderArray;
        if (indexPath.row) {
            senderArray = edusArray[indexPath.row - 1];
        }
        [self performSegueWithIdentifier:@"eduPush" sender:senderArray];
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
        cell = [positionTableView dequeueReusableCellWithIdentifier:@""];

    }
    return cell;
}

@end

