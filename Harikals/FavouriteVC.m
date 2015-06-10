//
//  FavouriteVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "FavouriteVC.h"
#import "FavourCell.h"


@interface FavouriteVC () <UITableViewDelegate, UITableViewDataSource> {
    
    __weak IBOutlet UITableView *mainTableView;
    
    NSMutableArray *favouriteData;
    UITableViewCell *footer;
    
    
    __weak IBOutlet UILabel *emptylabel;
    __weak IBOutlet UIButton *firstalaButton;
}

@end

@implementation FavouriteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    favouriteData = [NSMutableArray array];
    
    if (_isMessageVC) {
        emptylabel.text = @"Hiç mesajınız yok";
        firstalaButton.hidden = YES;
    }
    

    
    mainTableView.separatorColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    footer = [mainTableView dequeueReusableCellWithIdentifier:@"footer"];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0, 1000, 1.5);
    topBorder.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0].CGColor;
    
    [footer.layer addSublayer:topBorder];
    
    [favouriteData addObject:@"a"];
    [favouriteData addObject:@"b"];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!favouriteData.count) {
        mainTableView.hidden = YES;
    }
    return favouriteData.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavourCell *cell = [tableView dequeueReusableCellWithIdentifier:_isMessageVC ? @"dialogCell" : @"favouriteCell"];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"   SİL         ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  2 ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [favouriteData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isMessageVC) {
        [self performSegueWithIdentifier:@"openChat" sender:nil];
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
