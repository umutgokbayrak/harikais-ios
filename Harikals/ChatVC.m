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


#define CHAT_REFRESH_PERIOD 5

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
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    NSMutableArray *messagesArray;
    
    BOOL loaded;
    
    NSDateFormatter *formatter;
    NSString *direction1ImagePath;
    NSString *direction2ImagePath;
    
    NSTimer *fetchTimer;
    
    NSString *jobId;
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
    spinner.hidesWhenStopped = YES;
    mainTableView.contentInset = UIEdgeInsetsMake(5, 0, 10, 0);
    
    jobId = dataDictionary[@"id"];
    if ([dataDictionary[@"jobId"] length]) {
        jobId = dataDictionary[@"jobId"];
    }
    
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
    
    
    fetchTimer = [NSTimer scheduledTimerWithTimeInterval:CHAT_REFRESH_PERIOD target:self selector:@selector(loadNext) userInfo:nil repeats:YES];
}

- (void)loadNext {
    NSMutableDictionary *params = [@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : jobId} mutableCopy];
    
    if ([dataDictionary[@"chatId"] length]) {
        params [@"chatId"]  = dataDictionary[@"chatId"];
    }
    NSInteger prevCount = messagesArray.count;
    [Server callFunctionInBackground:@"chatLog" withParameters:params block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [messagesArray removeAllObjects];
            direction1ImagePath = receivedItems[@"images"][@"direction1"];
            direction2ImagePath = receivedItems[@"images"][@"direction2"];
            [messagesArray insertObjects:receivedItems[@"messages"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [receivedItems[@"messages"] count])]];
//            NSInteger difference = receivedItems.count - prevCount;
            NSMutableArray *indexPathes = [NSMutableArray array];
            for (NSInteger i = prevCount; i < [receivedItems[@"messages"] count]; i ++) {
                [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            if (indexPathes.count) {
                [mainTableView insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationNone];
                if (messagesArray.count) {
                    [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
        } else {
            
        }
    }];
}


- (void)loadMessages {
    [spinner startAnimating];
    NSMutableDictionary *params = [@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : jobId} mutableCopy];
    
    if ([dataDictionary[@"chatId"] length]) {
        params [@"chatId"]  = dataDictionary[@"chatId"];
    }

    [Server callFunctionInBackground:@"chatLog" withParameters:params block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [messagesArray removeAllObjects];
            direction1ImagePath = receivedItems[@"images"][@"direction1"];
            direction2ImagePath = receivedItems[@"images"][@"direction2"];
            [messagesArray insertObjects:receivedItems[@"messages"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [receivedItems[@"messages"] count])]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCounters" object:nil];
        } else {
            
        }
        [spinner stopAnimating];

        [mainTableView reloadData];
        if ([messagesArray count]) {
            [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messagesArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [fetchTimer invalidate];
    fetchTimer = [NSTimer scheduledTimerWithTimeInterval:CHAT_REFRESH_PERIOD target:self selector:@selector(loadNext) userInfo:nil repeats:YES];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"chatAlertShown"]) {
        [Server showFavouriteAlertWithTitle:@"Bilgi" text:@"Bu ekranda yaptığınız yazışmalar gizlidir. Firma yetkilisi sizin isminizi ve diğer profil bilgilerinizi göremeyecektir."];
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"chatAlertShown"];
    } else {

    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [fetchTimer invalidate];
}

- (void)loadDummyTextView {
    dummyTextView = [[UITextView alloc] init];
    dummyTextView.font = [UIFont fontWithName:@"OpenSans" size:16.0];
}

-(void)dealloc {
    [fetchTimer invalidate];
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
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length) {
        
        NSDictionary *params = @{@"userId" : Server.userInfoDictionary[@"userId"],
                                 @"jobId" : jobId,
                                 @"message" : text};
        [Server callFunctionInBackground:@"sendMessage"
                          withParameters:params
                                   block:^(NSDictionary *receivedItems, NSError *error) {
                                       if (receivedItems.count && !error) {
                                           [messagesArray addObject:@{@"direction" : @1,
                                                                      @"msg" : text,
                                                                      @"from" : @"Siz",
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
    
    NSObject *companyObj = dataDictionary[@"company"];

    NSString *companyName = (companyObj != nil && [companyObj isKindOfClass:[NSString class]]) ? dataDictionary[@"company"] : dataDictionary[@"company"][@"name"];
    
    NSString *fromString = direction % 2 != 0 ? @"Siz" : companyName;
    if ([fromString isEqualToString:@"You"]) {
        fromString = @"Siz";
    }
    cell.dateLabel.text = [NSString stringWithFormat:@"%@, %@", fromString, messagesArray[indexPath.row][@"date"]];
    
    
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
