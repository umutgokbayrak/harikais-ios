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
#import <PFLinkedInUtils.h>
#import "HKServer.h"


@interface LeftMenuViewController () {
    
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UIImageView *bottomLogo;
    
    NSArray *cellsIDsArray;
}

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    cellsIDsArray = @[@"cell1", @"cell2", @"cell3", @"cell4", @"cell5"];
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        bottomLogo.hidden = YES;
    }
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCards) name:@"presentCards" object:nil];
    
//    [PFCloud callFunctionInBackground:@"config" withParameters:nil block:^(id object, NSError *error) {
//        
//    }];
    [mainTableView reloadData];
//    [self getProfile];
}

- (void)getProfile {
    //        [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken]
    
//    PFObject *linkedInUser = [PFUser currentUser][@"linkedInUser"];
//    [linkedInUser fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        NSString *accessToken = object[@"accessToken"];
//        
//    [PFLinkedInUtils.linkedInHttpClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //            NSLog(@"Response JSON: %@", responseObject);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //            NSLog(@"Error: %@", error);
//        }];
//    }];
    

//    [PFLinkedInUtils.linkedInHttpClient getAuthorizationCode:^(NSString *authorizationCode) {
//    NSString *code = @"AQT2NBTs6cfe9Ek4hOKAjypzco6CAXwuQKNkAGWsB7e9gs0cWv4ga8UgyvlMk5hvRauRatiyVfO3BpMgJb64AxuCVC1zWgRPArvaCdp2RBl80C9gcac";
//        [PFLinkedInUtils.linkedInHttpClient getAccessToken:code success:^(NSDictionary *accessTokenDictionary) {
//            
//        } failure:^(NSError *accessTokenError) {
//            
//        }];
//    } cancel:^{
////
//    } failure:^(NSError *authorizationCodeError) {
////
//    }];
//    
}

- (IBAction)profileButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://touch.www.linkedin.com/#you"]]];
}

- (void)presentCards {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"firstViewController"]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
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
