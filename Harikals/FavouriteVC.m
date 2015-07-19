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
#import "HKServer.h"


@interface FavouriteVC () <UITableViewDelegate, UITableViewDataSource> {
    
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *dataArray;
    UITableViewCell *footer;
    CALayer *topBorder;
    
    __weak IBOutlet UILabel *emptylabel;
    __weak IBOutlet UIButton *firstalaButton;
    
    UIActivityIndicatorView *spinner;
    
    __weak IBOutlet UIImageView *downloadIconImageView;
    
    __weak IBOutlet UILabel *emptyDescriptionLabel;
    
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
    downloadIconImageView.hidden = YES;
    firstalaButton.hidden = YES;
    emptylabel.hidden = YES;
    emptyDescriptionLabel.hidden = emptylabel.hidden;

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    [spinner stopAnimating];
    [self.view addSubview:spinner];
    
    if (_isMessageVC) {
        downloadIconImageView.image = [UIImage imageNamed:@"big-chat-icon"];
        
        emptylabel.text = @"Hiç mesajınız yok";
        emptyDescriptionLabel.text = @"Size önerdiğimiz fırsatların\niçerisinden o firmanın İK sorumlusu\nile yaptığınız yazışmalara\nburadan ulaşabilirsiniz.";
        [self loadChats];
    } else {
        downloadIconImageView.image = [UIImage imageNamed:@"big-love-icon"];
        emptyDescriptionLabel.text = @"Size önerdiğimiz fırsatları\nfavorilere eklediğinizde\nistediğiniz zaman buradan\nonlara erişebilirsiniz.";

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
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0 / 255.0 green:50.0 / 255.0 blue:84.0 / 255.0 alpha:1.0]];
}

- (void)loadFavourites {
    [spinner startAnimating];
    [Server callFunctionInBackground:@"favorites" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
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

- (void)loadChats {
    [spinner startAnimating];
    [Server callFunctionInBackground:@"chats" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [dataArray removeAllObjects];
            [dataArray addObjectsFromArray:receivedItems];
        } else {
            //TODO:Remove NSLog
            NSLog(@"chats ERROR %@", error);
        }
        [spinner stopAnimating];
        [mainTableView reloadData];
    }];
}

- (void)configureCounterForCell:(FavourCell *)cell  count:(NSInteger)count {
    UILabel *countLabel = cell.counterView.subviews[0];
    countLabel.text = [NSString stringWithFormat:@"%d", count];
    cell.counterView.hidden = !count;
}


//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!spinner.isAnimating) {
        mainTableView.hidden = !dataArray.count;

        firstalaButton.hidden = dataArray.count;
        emptylabel.hidden = dataArray.count;
        emptyDescriptionLabel.hidden = emptylabel.hidden;
        downloadIconImageView.hidden = dataArray.count;
    }

    return dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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
        [self configureCounterForCell:cell count:[dataArray[indexPath.row][@"unreadCount"] integerValue]];
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
        NSDictionary *data = dataArray[indexPath.row];
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (_isMessageVC) {
            [self removeChatWithData:data];
        } else {
            [self removeFavouriteWithData:data];
        }
        
    }
}


- (void)removeFavouriteWithData:(NSDictionary *)data {
    [Server callFunctionInBackground:@"deleteFavorite" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"favoriteId"]
                                                                        } block:^(NSArray *receivedItems, NSError *error) {
                                                                            if (receivedItems) {
                                                                                //TODO:Remove NSLog
                                                                                NSLog(@"%@", receivedItems);
                                                                            } else {
                                                                                //TODO:Remove NSLog
                                                                                NSLog(@"%@", error);
                                                                            }
                                                                            
                                                                        }];
}

- (void)removeChatWithData:(NSDictionary *)data {
    [Server callFunctionInBackground:@"deleteChat" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : data[@"companyId"]
                                                                    } block:^(NSArray *receivedItems, NSError *error) {
                                                                        if (receivedItems) {
                                                                            //TODO:Remove NSLog
                                                                            NSLog(@"%@", receivedItems);
                                                                        } else {
                                                                            //TODO:Remove NSLog
                                                                            NSLog(@"%@", error);
                                                                        }
                                                                        
                                                                    }];
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
