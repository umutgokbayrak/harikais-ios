//
//  ChatVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ChatVC.h"
#import "ChatCell.h"
#import "HKServer.h"
#import <Parse.h>
#import <UIImageView+WebCache.h>

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
    
    NSDateFormatter *formatter;
    NSString *direction1ImagePath;
    NSString *direction2ImagePath;
}

@end

@implementation ChatVC
@synthesize dataDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messagesArray = [NSMutableArray array];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    [self loadDummyTextView];
    [[NSBundle mainBundle] loadNibNamed:@"ChatInputView" owner:self options:nil];
    inputTextView.delegate = self;
    inputTextView.contentInset = UIEdgeInsetsMake(3, 0, 3, 0);
    self.inputAccessoryView = inputVuew;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    mainTableView.delegate = self;
    mainTableView.dataSource = self;

    mainTableView.contentInset = UIEdgeInsetsMake(5, 0, 10, 0);
    
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        myWidth = 199;
        otherWidth = 229;
    } else if ([UIScreen mainScreen].bounds.size.height == 667){
        myWidth = 254;
        otherWidth = 284;
    } else if ([UIScreen mainScreen].bounds.size.height == 736){
        myWidth = 293;
        otherWidth = 323;
    } else {
        myWidth = 199;
        otherWidth = 229;
    }
    
    [self loadMessages];
    
}

- (void)loadMessages {
    [Server callFunctionInBackground:@"chatLog" withParameters:@{@"userId" : @"123",
                                                                 @"jobId" : dataDictionary[@"companyId"] ? dataDictionary[@"companyId"] : dataDictionary[@"id"]} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [messagesArray removeAllObjects];
            direction1ImagePath = receivedItems[@"images"][@"direction1"];
            direction2ImagePath = receivedItems[@"images"][@"direction2"];
            [messagesArray addObjectsFromArray:receivedItems[@"messages"]];
        } else {

        }

        [mainTableView reloadData];
    }];
}

- (void)loadDummyTextView {
    dummyTextView = [[UITextView alloc] init];
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:16.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (messagesArray.count) {
        [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:loaded];
    }
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
    
    
    [Server callFunctionInBackground:@"sendMessage"
                      withParameters:@{@"userId" : @"123",
                                       @"jobId" : dataDictionary[@"companyId"],
                                       @"msg" : text}
                               block:^(NSDictionary *receivedItems, NSError *error) {
       if (receivedItems.count && !error) {
           [messagesArray addObject:@{@"direction" : @1,
                                      @"msg" : text,
                                      @"from" : @"You",
                                      @"date" : [formatter stringFromDate:[NSDate date]]
                                      }];
           NSIndexPath *indexpath = [NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0];
           [self textViewDidChange:inputTextView];
           [mainTableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationBottom];
           [mainTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
       } else {
           //TODO:Remove NSLog
           NSLog(@"failed to send message %@", error);
       }
    }];
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

    dummyTextView.text = messagesArray[indexPath.row][@"msg"];
    BOOL isMine = [messagesArray[indexPath.row][@"direction"] integerValue] % 2 != 0 ;
    
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:isMine ? 16 : 16];
    CGFloat resultHeight = [dummyTextView sizeThatFits:CGSizeMake(isMine ? myWidth : otherWidth, FLT_MAX)].height;
    return MAX((resultHeight + 33), 74);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger direction = [messagesArray[indexPath.row][@"direction"] integerValue];
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:direction % 2 != 0 ? @"myChatCell" : @"otherChatCell"];
    cell.messageTextView.text = messagesArray[indexPath.row][@"msg"];
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2.0;

    cell.dateLabel.text = [NSString stringWithFormat:@"%@, %@", messagesArray[indexPath.row][@"from"], messagesArray[indexPath.row][@"date"]];
    
    
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:direction == 1 ? direction1ImagePath : direction2ImagePath]
     placeholderImage:[UIImage imageNamed:@"avatar"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if ([dataDict isEqual:favouriteObject]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                avatarImageView.image = image;
//            });
//        }
    }];
    
    return cell;
}

@end
