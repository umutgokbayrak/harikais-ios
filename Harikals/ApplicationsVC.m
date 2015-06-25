//
//  ApplicationsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "ApplicationsVC.h"
#import "ApplicationsCell.h"
#import <Parse.h>

@interface ApplicationsVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    
    __weak IBOutlet UIButton *firstalaButton;
    __weak IBOutlet UILabel *emptyLabel;
    __weak IBOutlet NSLayoutConstraint *lineTopSpacing;
    __weak IBOutlet UITableView *mainTableView;
    ApplicationsCell *profileCell;
    
    NSMutableArray *dataArray;
}

@end

@implementation ApplicationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [NSMutableArray array];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    [self loadApplications];
    profileCell = [mainTableView dequeueReusableCellWithIdentifier:@"profileCell"];
    
    [firstalaButton addTarget:self action:@selector(presentCards) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:firstalaButton];
}

- (void)presentCards {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentCards" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71.0 / 255.0 green:160.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]];
}

- (void)loadApplications {
    [PFCloud callFunctionInBackground:@"applications" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:receivedItems];
        } else {
            //TODO:Remove NSLog
            NSLog(@"favs ERROR %@", error);
        }
        
        [mainTableView reloadData];
    }];
}



//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    emptyLabel.hidden = dataArray.count;
    firstalaButton.hidden = dataArray.count;
    tableView.scrollEnabled = dataArray.count;
    
    return dataArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApplicationsCell *cell;
    if (!indexPath.row) {
        
        return profileCell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier: indexPath.row % 2 == 0 ? @"leftAlignmentCell" : @"rightAlignmentCell"];
    
    [cell configureApplication:dataArray[indexPath.row - 1]];
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
