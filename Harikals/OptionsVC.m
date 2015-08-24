//
//  OptionsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/4/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "OptionsVC.h"
#import "ProfileCell.h"
#import "HKServer.h"

@interface OptionsVC () <UITableViewDelegate, UITableViewDataSource> {
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    __weak IBOutlet UITableView *mainTableView;
}

@end

@implementation OptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    spinner.hidesWhenStopped = YES;
    self.title = @"Fonksiyon";
    [self loadOptions];
}

- (void)loadOptions {
    [spinner startAnimating];
    mainTableView.hidden = YES;
    [Server callFunctionInBackground:@"functionNames" withParameters:@{} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            _dataArray = receivedItems;
            mainTableView.hidden = NO;
        } else {
            //TODO:Remove NSLog
            NSLog(@"opport ERROR %@", error);
        }
        [spinner stopAnimating];
        [mainTableView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.screenName = @"OptionsVC";
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if ([mainTableView indexPathForSelectedRow]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateJobFunction" object:_dataArray[[mainTableView indexPathForSelectedRow].row]];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showErrorAlert:@"Lütfen kendinize çalışmak istediğiniz bir fonksiyon seçer misi- niz?"];
    }

 
}
- (void)showErrorAlert:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"Kapat" otherButtonTitles:nil];
    [alert show];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkCell"];
    cell.nameLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
