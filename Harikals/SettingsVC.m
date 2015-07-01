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
    
    [selectedLocations addObject:@""];
    [selectedLocations addObject:@""];
    [selectedLocations addObject:@""];
    
    middleHolder.layer.cornerRadius =  3;
    topHolder.layer.cornerRadius =  3;
    lastHolder.layer.cornerRadius =  3;
    
    dropdownTableView.layer.borderWidth = 0.5;
    dropdownTableView.layer.borderColor = [UIColor colorWithRed:151.0 / 255.0 green:151.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor;

    
    priceTextField.delegate = self;
    priceTextField.keyboardType = UIKeyboardTypeNumberPad;
    mainTableView.dataSource = self;
    searchTextField.delegate = self;
    mainTableView.delegate = self;
    [self updateTableViewHeight];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self reloadDropMenu];
}

- (void)reloadDropMenu {
    [dropdownTableView reloadData];
    dropdownMenuHeight.constant = 35 * dropMenuOptions.count;
    dropdownTableView.hidden = !dropMenuOptions.count;
    tap.enabled = !dropMenuOptions.count;
}

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath{
//    [CATransaction begin];
    [selectedLocations removeObjectAtIndex:indexPath.row];

    [self updateTableViewHeight];
//    [mainTableView beginUpdates];
//    [CATransaction setCompletionBlock: ^{
//
//    }];
    [mainTableView deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation: UITableViewRowAnimationLeft];
//    [mainTableView endUpdates];
//    [CATransaction commit];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:priceTextField]) {
        if (![self verifyPriceWithText:string]) {
            return NO;
        }
    } else {
        
        [dropMenuOptions removeAllObjects];
        [dropMenuOptions addObject:@""];
        [dropMenuOptions addObject:@""];
        [dropMenuOptions addObject:@""];
        [dropMenuOptions addObject:@""];
        [self reloadDropMenu];

    }
    return  YES;
}

- (IBAction)addPressed:(id)sender {
    if (searchTextField.text.length) {
        searchTextField.text = @"";
        [selectedLocations addObject:@""];
        [mainTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedLocations.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateTableViewHeight];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"   SİL         ";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeRowAtIndexPath:indexPath];

    }

}

@end
