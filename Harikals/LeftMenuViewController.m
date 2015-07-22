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
#import <UIImageView+WebCache.h>
#import "MenuCell.h"
#import <Parse.h>
#import <PFLinkedInUtils.h>
#import "HKServer.h"
#import <UIView+Position.h>
#import "ProfileVC.h"


@interface LeftMenuViewController () {
    
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UIImageView *bottomLogo;
    
    __weak IBOutlet UIImageView *avatarImageView;
    __weak IBOutlet UILabel *nameLabel;
    
    
    MenuCell *firstalarCell;
    MenuCell *messageCell;
    
    __weak IBOutlet UILabel *positionLabel;
    NSArray *cellsIDsArray;
    
    NSNumber *firstalarNumber;
    NSNumber *messagesNumber;
    
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
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"menuFirstShown"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"menuFirstShown"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [Server showAlertWithText:@"Harika İş size iş fırsatlarını bildirim mesajları ile iletecektir. Bir sonraki ekranda sizden izin isteyeceğiz." closeButton:@"OK"];
            
        });
    }
    
    
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCards) name:@"presentCards" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentApplications) name:@"presentApplications" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMessages) name:@"presentMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAvatarPicked:) name:@"userAvatarPicked" object:nil];
    
    
    NSDictionary *personal  = [[NSUserDefaults standardUserDefaults] objectForKey:@"personal"];
    nameLabel.text = personal[@"fullname"];
    positionLabel.text = personal[@"headline"];
    
    NSString *pictureUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageUrl"];
    if (pictureUrl) {
        [self updateAvatarWithUrl:pictureUrl];
    }
    
    [Server callFunctionInBackground:@"info" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary * object, NSError *error) {
        if (object) {
            nameLabel.text = object[@"fullname"];
            [self updateAvatarWithUrl:object[@"pictureUrl"]];
            [[NSUserDefaults standardUserDefaults] setObject:object[@"pictureUrl"] forKey:@"imageUrl"];
        }

    }];

    avatarImageView.layer.cornerRadius = avatarImageView.frameWidth / 2.0;
    avatarImageView.clipsToBounds = YES;
    
    positionLabel.text = @"";

    [mainTableView reloadData];
    [self refreshCounters];
}

- (void)userAvatarPicked:(NSNotification *)notification {
    UIImage *image = notification.object;
    if (image) {
        avatarImageView.image = image;
    }
}


- (void)updateAvatarWithUrl:(NSString *)urlString {
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

- (void)getProfile {
    
}

- (void)configureCounterForCell:(MenuCell *)cell  count:(NSInteger)count {
    UILabel *countLabel = cell.counterView.subviews[0];
    countLabel.text = [NSString stringWithFormat:@"%d", count];
    cell.counterView.hidden = !count;
}


- (IBAction)profileButtonPressed:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://touch.www.linkedin.com/#you"]]];
    
    
    [Server callFunctionInBackground:@"profile" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            ProfileVC *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
            profileVC.inputDictionary = receivedItems;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController: profileVC] animated:YES completion:^{
                
            }];
        } else {
            
        }
        
    }];
    
    
    
}

- (void)presentCards {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"firstViewController"]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)presentMessages {
    FavouriteVC *messageVC;
    messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"];
    messageVC.isMessageVC = YES;
    messageVC.title = @"Mesajlar";
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:messageVC] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}


- (void)presentApplications {
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"applications"]]
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

- (void)refreshCounters {
    [Server callFunctionInBackground:@"unreadOpportCount" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            firstalarNumber = receivedItems[@"count"];
            [self configureCounterForCell:firstalarCell count:firstalarNumber.integerValue];
        } else {
            //TODO:Remove NSLog
            NSLog(@"opport ERROR %@", error);
        }

        [mainTableView reloadData];
    }];
    
    [Server callFunctionInBackground:@"unreadMsgCount" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSDictionary *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            messagesNumber = receivedItems[@"count"];
            Server.unreadCount = messagesNumber;
            [self configureCounterForCell:messageCell count:messagesNumber.integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadCount" object:nil];
        } else {
            //TODO:Remove NSLog
            NSLog(@"opport ERROR %@", error);
        }
        
        [mainTableView reloadData];
    }];
    
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
    if (indexPath.row == 0) {
        firstalarCell = cell;
        [self configureCounterForCell:firstalarCell count:firstalarNumber.integerValue];
    } else if (indexPath.row == 3) {
        messageCell = cell;
        [self configureCounterForCell:messageCell count:messagesNumber.integerValue];
    }
    return cell;
}

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    if (menuViewController) {
        [self refreshCounters];
    }
}

@end
