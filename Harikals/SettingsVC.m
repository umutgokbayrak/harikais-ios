//
//  SettingsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "SettingsVC.h"
#import "DropdownModel.h"
#import "HKServer.h"
#import <Parse.h>
#import "SettingsCell.h"
#import <UIView+Position.h>


@interface SettingsVC ()  <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,DropMenuDelegate>{
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    __weak IBOutlet UIView *lastHolder;
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UITextField *priceTextField;
    __weak IBOutlet UISwitch *notificationsSwitch;
    __weak IBOutlet UIView *middleHolder;
    __weak IBOutlet UIView *topHolder;
    
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
    
    DropdownModel *dropdownModel;
    
    __weak IBOutlet UIActivityIndicatorView *spinnerAutocomplete;
    NSMutableArray *selectedLocations;
    UITapGestureRecognizer *tap;
    
    NSMutableArray *dropMenuOptions;
    
    __weak IBOutlet NSLayoutConstraint *dropdownMenuHeight;
    
    __weak IBOutlet UITableView *dropdownTableView;
    
    __weak IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
    __weak IBOutlet UIScrollView *mainScrollView;
    
}

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    selectedLocations = [NSMutableArray array];
    dropMenuOptions = [NSMutableArray array];
    
    spinner.hidesWhenStopped = YES;
    mainScrollView.hidden = YES;
    [Server callFunctionInBackground:@"settings" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems) {
            
            [selectedLocations addObjectsFromArray:receivedItems[@"places"]];
            if ([receivedItems[@"notifications"] isKindOfClass:[NSNull class]]) {
                notificationsSwitch.on = NO;
            } else {
                notificationsSwitch.on = [receivedItems[@"notifications"] integerValue];
            }

            priceTextField.text = [NSString stringWithFormat:@"%@",  receivedItems[@"salary"] ? receivedItems[@"salary"] : @""];
            if ([priceTextField.text isEqualToString:@"0"]) {
                priceTextField.text = @"";
            }
            [mainTableView reloadData];
            [self updateTableViewHeight];
            mainScrollView.hidden = NO;

        } else {

        }
        [spinner stopAnimating];
    }];
    
    dropdownModel = [[DropdownModel alloc] init];
    dropdownTableView.delegate = dropdownModel;
    dropdownTableView.dataSource = dropdownModel;
    dropdownModel.dataArray = dropMenuOptions;
    
    dropdownModel.delegate = self;
    
    middleHolder.layer.cornerRadius =  3;
    topHolder.layer.cornerRadius =  3;
    lastHolder.layer.cornerRadius =  3;
    
    dropdownTableView.layer.borderWidth = 0.5;
    dropdownTableView.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;
    [notificationsSwitch addTarget:self action:@selector(changeNotifs:) forControlEvents:UIControlEventValueChanged];
    
    priceTextField.delegate = self;
    priceTextField.keyboardType = UIKeyboardTypeNumberPad;
    mainTableView.dataSource = self;
    searchTextField.delegate = self;
    mainTableView.delegate = self;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:priceTextField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    priceTextField.inputAccessoryView = toolbar;
    
    [self updateTableViewHeight];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [searchTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self reloadDropMenu];
    [spinnerAutocomplete stopAnimating];
}

- (void)changeNotifs:(UISwitch *)notifsSwitch {
    [Server callFunctionInBackground:@"updateNotification" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"notification" : notificationsSwitch.on ? @"true" : @"false"} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems) {
            //TODO:Remove NSLog
            NSLog(@"%@", receivedItems);
        } else {
            //TODO:Remove NSLog
            NSLog(@"%@", error);
        }
        
    }];
}

- (void)didSelectOption:(NSString *)optionString optionsArray:(NSMutableArray *)array {
    searchTextField.text = optionString;
}

- (void)reloadDropMenu {
    [dropdownTableView reloadData];

    dropdownMenuHeight.constant = 35 * dropMenuOptions.count;
    dropdownTableView.hidden = !dropMenuOptions.count;
    tap.enabled = !dropMenuOptions.count;
}


- (void)auticompleteLocationWithText:(NSString *)text {
    NSString *savedtext = [text copy];
    if (!text.length) {
        [dropMenuOptions removeAllObjects];
        [self reloadDropMenu];
        [spinnerAutocomplete stopAnimating];
    } else {
        if (!spinnerAutocomplete.isAnimating) {
            [spinnerAutocomplete startAnimating];
        }
        [Server callFunctionInBackground:@"autocompleteLocation" withParameters:@{@"str" : savedtext} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                [dropMenuOptions removeAllObjects];
                if ([savedtext isEqualToString:searchTextField.text]) {
                    [dropMenuOptions addObjectsFromArray:receivedItems];
                }
                [self reloadDropMenu];
                if (dropdownMenuHeight.constant > 10) {
//                    [self scrollToBottom];
                }
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            [spinnerAutocomplete stopAnimating];
        }];
    }
}

- (void)scrollToBottom {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mainScrollView setContentOffset:CGPointMake(0, dropdownTableView.frameY - 50)];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath{
    [selectedLocations removeObjectAtIndex:indexPath.row];
    [self updateTableViewHeight];
    [mainTableView deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation: UITableViewRowAnimationLeft];
}

- (void)hideKeyboard {
    [dropMenuOptions removeAllObjects];
    [self reloadDropMenu];
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
}

- (void)updateTableViewHeight {

    tableViewHeightConstraint.constant = 50 * selectedLocations.count;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
       
    }];
}

- (BOOL)verifyPriceWithText:(NSString *)text {
    NSMutableString *mutString = [[NSMutableString alloc] initWithString:text];
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:0 error:nil];
    [regexp replaceMatchesInString:mutString options:0 range:NSMakeRange(0, mutString.length) withTemplate:@""];

    
    return !mutString.length;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField  {
    if ([textField isEqual:priceTextField]) {
        if (![self verifyPriceWithText:textField.text]) {
            return NO;
        }
    }
    [textField resignFirstResponder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:priceTextField]) {
        
    if ([textField.text integerValue] > 500000) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aylık net bu maaşı beklediğinizden emin misiniz? Size uygun pozisyon bulmamız biraz zor olabilir :)" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        [textField becomeFirstResponder];
        return;
    }
        NSString *salaryValue = textField.text;
        if (!salaryValue.length) {
            salaryValue = @"0";
        }
        [Server callFunctionInBackground:@"updateSalary" withParameters:@{@"salary" : salaryValue, @"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                NSLog(@"salary %@", receivedItems);
                
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:priceTextField]) {
        if (![self verifyPriceWithText:string]) {
            return NO;
        }
    } else {

    }
    return  YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self auticompleteLocationWithText:textField.text];
}


- (NSInteger)lengthOfTrimmedString:(NSString *)string {
    return  [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length;
}
- (IBAction)addPressed:(id)sender {
    if ([self lengthOfTrimmedString:searchTextField.text] < 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen çalışmak isteyebile-ceğiniz yerin ismini kontrol ediniz" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
    } else {
        searchTextField.text = @"";
        NSIndexPath *selectedIndexPath = [dropdownTableView indexPathForSelectedRow];
        if (selectedIndexPath) {
            NSString *location = dropMenuOptions[selectedIndexPath.row];
            
            [Server callFunctionInBackground:@"addNewLocation" withParameters:@{@"location" : location, @"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
                if (receivedItems) {
                    [selectedLocations addObject:location];
                    [mainTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedLocations.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self updateTableViewHeight];
                } else {
                    //TODO:Remove NSLog
                    NSLog(@"%@", error);
                }
                
            }];
        }
        [self hideKeyboard];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0 / 255.0 green:50.0 / 255.0 blue:84.0 / 255.0 alpha:1.0]];
}


- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];
    
    scrollViewBottomConstraint.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;
    
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mainScrollView setContentOffset:CGPointMake(0, priceTextField.frameY + 50)];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
}


#pragma mark - UITableView Data Source Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return selectedLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    cell.locationLabel.text = selectedLocations[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"   SİL         ";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *location = selectedLocations[indexPath.row];
        [self removeRowAtIndexPath:indexPath];
        [Server callFunctionInBackground:@"deleteLocation" withParameters:@{@"location" : location, @"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {

                
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
        
        
    }

}

@end
