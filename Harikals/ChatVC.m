//
//  ChatVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ChatVC.h"
#import "ChatCell.h"


@interface ChatVC () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITextField *inputTextField;
    __weak IBOutlet UITextView *inputTextView;
    
    __weak IBOutlet NSLayoutConstraint *textViewHeight;
    __weak IBOutlet UILabel *placeHolderLabel;
    __weak IBOutlet UITableView *mainTableView;
    
    __weak IBOutlet UIView *inputVuew;
    __weak IBOutlet NSLayoutConstraint *tableViewBottomSpacing;
    
    __weak IBOutlet NSLayoutConstraint *tableViewTopSpacing;
    
    CGFloat myWidth;
    CGFloat otherWidth;
    
    UITextView *dummyTextView;

    CGRect keyboardEndFrame;
    
    NSMutableArray *messagesArray;
    
    BOOL loaded;
}

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messagesArray = [NSMutableArray array];
    [messagesArray addObject:@{@"direction" : @1, @"message" : @"Merhaba bu \nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @2, @"message" : @"Merhaba bu \nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @2, @"message" : @"Merhaba bu \nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @1, @"message" : @"Merhaba bu \nMerhaba bu\nMerhaba bu\nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @1, @"message" : @"Merhaba bu \nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @2, @"message" : @"Merhaba bu \nMerhaba bu\nMerhaba bu\nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @2, @"message" : @"Merhaba bu \nMerhaba bu"}];
    [messagesArray addObject:@{@"direction" : @1, @"message" : @"Merhaba bu \nMerhaba bu"}];
    
    [self loadDummyTextView];
    [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    inputTextView.delegate = self;
    inputTextView.contentInset = UIEdgeInsetsMake(3, 0, 3, 0);
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
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:16.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:loaded];
    loaded = YES;
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];

    tableViewBottomSpacing.constant = self.view.frame.size.height - keyboardEndFrame.origin.y + 63;

    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    NSIndexPath *indexPath = [[mainTableView indexPathsForVisibleRows] lastObject];
    
    
#warning curve in ios 7
    
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    } completion:^(BOOL finished) {

    }];
    
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    placeHolderLabel.hidden = textView.text.length;
}

- (IBAction)sendPressed:(id)sender {
    NSString *text = inputTextView.text;
    inputTextView.text = @"";
    [messagesArray addObject:@{@"direction" : @1, @"message" : text}];
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0];
    [self textViewDidChange:inputTextView];
    [mainTableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationBottom];
//    [mainTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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

    dummyTextView.text = messagesArray[indexPath.row][@"message"];
    BOOL isMine = [messagesArray[indexPath.row][@"direction"] integerValue] % 2 != 0 ;
    
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:isMine ? 16 : 15];
    CGFloat resultHeight = [dummyTextView sizeThatFits:CGSizeMake(isMine ? myWidth : otherWidth, FLT_MAX)].height;
    return MAX((resultHeight + 33), 74);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[messagesArray[indexPath.row][@"direction"] integerValue] % 2 != 0 ? @"myChatCell" : @"otherChatCell"];
    cell.messageTextView.text = messagesArray[indexPath.row][@"message"];

    return cell;
}

@end
