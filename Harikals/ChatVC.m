//
//  ChatVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ChatVC.h"
#import "ChatCell.h"


@interface ChatVC () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITextField *inputTextField;
    
    __weak IBOutlet UITableView *mainTableView;
    
    __weak IBOutlet UIView *inputVuew;
    __weak IBOutlet NSLayoutConstraint *tableViewBottomSpacing;
    
    __weak IBOutlet NSLayoutConstraint *tableViewTopSpacing;
    
    CGFloat myWidth;
    CGFloat otherWidth;
    
    UITextView *dummyTextView;
    NSString *inputText;
}

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];

    inputText = @"Merhaba bu \nMerhaba bu";
    
    [self loadDummyTextView];
    [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    inputTextField.delegate = self;
    
    self.inputAccessoryView = inputVuew;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    mainTableView.delegate = self;
    mainTableView.dataSource = self;

    mainTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    
    myWidth = 199;
    otherWidth = 229;
    
}

- (void)loadDummyTextView {
    dummyTextView = [[UITextView alloc] init];
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:15.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_fromDetail) {
        [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
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
//    BOOL isMine = data[]
    dummyTextView.text = inputText;
    CGFloat resultHeight = [dummyTextView sizeThatFits:CGSizeMake(indexPath.row % 2 == 0 ? myWidth : otherWidth, FLT_MAX)].height;
    return MAX((resultHeight + 33), 74);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fromDetail) return 0;
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:indexPath.row % 2 == 0 ? @"myChatCell" : @"otherChatCell"];
    cell.messageTextView.text = inputText;
    return cell;
}

@end
