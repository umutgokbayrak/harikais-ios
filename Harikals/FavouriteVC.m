//
//  FavouriteVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "FavouriteVC.h"
#import "FavourCell.h"
#import <Parse.h>
#import "ChatVC.h"

@interface FavouriteVC () <UITableViewDelegate, UITableViewDataSource> {
    
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *dataArray;
    UITableViewCell *footer;
    CALayer *topBorder;
    
    __weak IBOutlet UILabel *emptylabel;
    __weak IBOutlet UIButton *firstalaButton;
}

@end

@implementation FavouriteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [NSMutableArray array];

    mainTableView.separatorColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    footer = [mainTableView dequeueReusableCellWithIdentifier:@"footer"];
    
    topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0, 1000, 1.5);
    topBorder.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0].CGColor;
    
    [footer.layer addSublayer:topBorder];
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    
    
    if (_isMessageVC) {
        emptylabel.text = @"Hiç mesajınız yok";
        firstalaButton.hidden = YES;
        [self loadChats];
    } else {
        [self loadFavourites];
    }
    [firstalaButton addTarget:self action:@selector(presentCards) forControlEvents:UIControlEventTouchUpInside];
}

- (void)presentCards {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentCards" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71.0 / 255.0 green:160.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]];
}

- (void)loadFavourites {
    [PFCloud callFunctionInBackground:@"favorites" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId]} block:^(NSArray *receivedItems, NSError *error) {
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

- (void)loadChats {
    [PFCloud callFunctionInBackground:@"chats" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:receivedItems];
        } else {
            //TODO:Remove NSLog
            NSLog(@"chats ERROR %@", error);
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

    mainTableView.hidden = !dataArray.count;

    return dataArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    topBorder.frame = CGRectMake(0.0f, 0, 1000, 1.5);
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavourCell *cell = [tableView dequeueReusableCellWithIdentifier:_isMessageVC ? @"dialogCell" : @"favouriteCell"];
    
    if (_isMessageVC) {
        [cell configureChat:dataArray[indexPath.row]];
    } else {
        [cell configureFavourite:dataArray[indexPath.row]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"   SİL         ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  2;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isMessageVC) {
        [self performSegueWithIdentifier:@"openChat" sender:dataArray[indexPath.row]];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openChat"]) {
        ChatVC *chatVC = segue.destinationViewController;
        chatVC.dataDictionary = sender;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
