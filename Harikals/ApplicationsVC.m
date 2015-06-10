//
//  ApplicationsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ApplicationsVC.h"

@interface ApplicationsVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    
    __weak IBOutlet UIButton *firstalaButton;
    __weak IBOutlet UILabel *emptyLabel;
    __weak IBOutlet NSLayoutConstraint *lineTopSpacing;
    __weak IBOutlet UITableView *mainTableView;
}

@end

@implementation ApplicationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71.0 / 255.0 green:160.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    emptyLabel.hidden = YES;
    firstalaButton.hidden = YES;
    tableView.scrollEnabled = YES;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (!indexPath.row) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier: indexPath.row % 2 == 0 ? @"leftAlignmentCell" : @"rightAlignmentCell"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) return 125;
    return 70;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    lineTopSpacing.constant = -scrollView.contentOffset.y + 50;
}

@end
