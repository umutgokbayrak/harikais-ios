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
#import "HKServer.h"


@interface ApplicationsVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    
    __weak IBOutlet UIButton *firstalaButton;
    __weak IBOutlet UILabel *emptyLabel;
    __weak IBOutlet NSLayoutConstraint *lineTopSpacing;
    __weak IBOutlet UITableView *mainTableView;
    ApplicationsCell *profileCell;
    __weak IBOutlet UIImageView *lineImageView;
    
    NSMutableArray *dataArray;
    UIActivityIndicatorView *spinner;
    __weak IBOutlet UILabel *emptyDescriptionLabel;
    
    __weak IBOutlet UIImageView *downloadIcon;
    
}

@end

@implementation ApplicationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [NSMutableArray array];
    mainTableView.dataSource = self;
    
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    [spinner stopAnimating];
    [self.view addSubview:spinner];
    
    mainTableView.delegate = self;
    
    
    emptyDescriptionLabel.text = @"Başvurularınızla ilgili sormak\nistediğiniz bir konu olduğunda\nbizimle iletişime geçiniz.";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:emptyDescriptionLabel.text];
    [attrString addAttribute:NSFontAttributeName value:emptyDescriptionLabel.font range:NSMakeRange(0, emptyDescriptionLabel.text.length)];
    [attrString addAttribute:NSForegroundColorAttributeName value:emptyDescriptionLabel.textColor range:NSMakeRange(0, emptyDescriptionLabel.text.length)];
    
    [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(emptyDescriptionLabel.text.length - 18, 17)];
    
    emptyDescriptionLabel.attributedText = attrString;
    
    
    emptyLabel.hidden = YES;
    firstalaButton.hidden = YES;
    mainTableView.scrollEnabled = NO;
    mainTableView.hidden = YES;
    lineImageView.hidden = YES;
    emptyDescriptionLabel.hidden = emptyLabel.hidden;
    downloadIcon.hidden = emptyLabel.hidden;
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
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0 / 255.0 green:50.0 / 255.0 blue:84.0 / 255.0 alpha:1.0]];
}

- (void)loadApplications {
    [spinner startAnimating];
    [Server callFunctionInBackground:@"applications" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:receivedItems];
        } else {
            //TODO:Remove NSLog
            NSLog(@"favs ERROR %@", error);
        }
        [spinner stopAnimating];
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
    if (!spinner.isAnimating) {
        emptyLabel.hidden = dataArray.count;
        firstalaButton.hidden = dataArray.count;
        tableView.scrollEnabled = dataArray.count;
        emptyDescriptionLabel.hidden = emptyLabel.hidden;
        downloadIcon.hidden = emptyLabel.hidden;
    }
    
    mainTableView.hidden = spinner.isAnimating || !dataArray.count;
    lineImageView.hidden = spinner.isAnimating || !dataArray.count;
    
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
