//
//  LeftMenuViewController.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/10/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "UIViewController+RESideMenu.h"
#import "FavouriteVC.h"
#import "MenuCell.h"
#import <Parse.h>


@interface LeftMenuViewController () {
    
    __weak IBOutlet UITableView *mainTableView;
    
    NSArray *cellsIDsArray;
}

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellsIDsArray = @[@"cell1", @"cell2", @"cell3", @"cell4", @"cell5"];
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    
//    [PFCloud callFunctionInBackground:@"config" withParameters:nil block:^(id object, NSError *error) {
//        
//    }];
    [mainTableView reloadData];
    
}

- (IBAction)profileButtonPressed:(id)sender {
    
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell hideTint:NO];
    
    FavouriteVC *messageVC;
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"firstViewController"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
        case 2:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"applications"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"];
            messageVC.isMessageVC = YES;
            messageVC.title = @"Mesajlar";
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:messageVC] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;

        case 4:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"settings"]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = (MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell hideTint:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellsIDsArray[indexPath.row]];
    return cell;
}

@end
