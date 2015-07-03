//
//  SettingsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/12/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "SettingsVC.h"
#import "DropdownModel.h"
#import "DropdownModel.h"
#import "HKServer.h"
#import <Parse.h>
#import "SettingsCell.h"

@interface SettingsVC ()  <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>{
    
    __weak IBOutlet UIView *lastHolder;
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UITextField *priceTextField;
    __weak IBOutlet UISwitch *notificationsSwitch;
    __weak IBOutlet UIView *middleHolder;
    __weak IBOutlet UIView *topHolder;
    
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
    
    DropdownModel *dropdownModel;
    
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
    
    dropdownModel = [[DropdownModel alloc] init];
    dropdownTableView.delegate = dropdownModel;
    dropdownTableView.dataSource = dropdownModel;
    dropdownModel.dataArray = dropMenuOptions;
    
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
    [self updateTableViewHeight];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [searchTextField addTarget:self   action:@selector(textFieldDidChange:)  forControlEvents:UIControlEventEditingChanged];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self reloadDropMenu];
}

- (void)changeNotifs:(UISwitch *)notifsSwitch {
    [Server callFunctionInBackground:@"updateNotification" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId], @"notification" : notificationsSwitch.on ? @"true" : @"false"} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems) {
            //TODO:Remove NSLog
            NSLog(@"%@", receivedItems);
        } else {
            //TODO:Remove NSLog
            NSLog(@"%@", error);
        }
        
    }];
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
    } else {
        [Server callFunctionInBackground:@"autocompleteLocation" withParameters:@{@"str" : savedtext} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {
                [dropMenuOptions removeAllObjects];
                if ([savedtext isEqualToString:searchTextField.text]) {
                    [dropMenuOptions addObjectsFromArray:receivedItems];
                }
                [self reloadDropMenu];
                
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
    }
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
        [Server callFunctionInBackground:@"updateSalary" withParameters:@{@"salary" : textField.text, @"userID" : @"123"} block:^(NSArray *receivedItems, NSError *error) {
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

- (IBAction)addPressed:(id)sender {
    if (searchTextField.text.length) {
        searchTextField.text = @"";
        NSIndexPath *selectedIndexPath = [dropdownTableView indexPathForSelectedRow];
        if (selectedIndexPath) {
            NSString *location = dropMenuOptions[selectedIndexPath.row];
            
            [Server callFunctionInBackground:@"addNewLocation" withParameters:@{@"location" : location, @"userID" : @"123"} block:^(NSArray *receivedItems, NSError *error) {
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
    }
    [self hideKeyboard];
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
        [Server callFunctionInBackground:@"deleteLocation" withParameters:@{@"location" : location, @"userID" : @"123"} block:^(NSArray *receivedItems, NSError *error) {
            if (receivedItems) {

                
            } else {
                //TODO:Remove NSLog
                NSLog(@"%@", error);
            }
            
        }];
        
        
    }

}

@end
