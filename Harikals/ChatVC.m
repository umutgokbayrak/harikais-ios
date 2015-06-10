//
//  ChatVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITextField *inputTextField;
    
//    __weak IBOutlet NSLayoutConstraint *inputBottomSpacing;
    __weak IBOutlet UITableView *mainTableView;
    
    __weak IBOutlet UIView *inputVuew;
    __weak IBOutlet NSLayoutConstraint *tableViewBottomSpacing;
    
    __weak IBOutlet NSLayoutConstraint *tableViewTopSpacing;
}

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    inputTextField.delegate = self;
    
    self.inputAccessoryView = inputVuew;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    mainTableView.delegate = self;
    mainTableView.dataSource = self;

    mainTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [self.view layoutIfNeeded];

    tableViewBottomSpacing.constant = self.view.frame.size.height - keyboardEndFrame.origin.y + 63;


    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    NSIndexPath *indexPath = [[mainTableView indexPathsForVisibleRows] lastObject];
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    } completion:^(BOOL finished) {

    }];
    
}






-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)sendPressed:(id)sender {
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 139;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myChatCell"];
    
    return cell;
}

@end
