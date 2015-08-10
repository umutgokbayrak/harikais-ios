//
//  CardsVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/9/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "CardsVC.h"
#import <UIView+Position.h>
#import "CardView.h"
#import <Parse.h>
#import "DetailVC.h"
#import "HKServer.h"
#import "ChatVC.h"


@interface CardsVC () <UIScrollViewDelegate, iCarouselDataSource, iCarouselDelegate, CardViewDelegate> {
    __weak IBOutlet UIView *emptyHolderView;
    NSMutableDictionary *photoDictionary;
    __weak IBOutlet UIImageView *logoImageView;
    __weak IBOutlet UIButton *messagesButton;
    
    __weak DetailVC *presentedDetail;
    
    __weak IBOutlet UIImageView *downloadIcon;
    NSInteger totalImagesCount;
    __weak IBOutlet UIButton *applicationsButton;
    
    __weak IBOutlet UIView *counterView;
    NSNumber *unreadCount;
    
    NSInteger finishedImages;
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation CardsVC

@synthesize  menuButton;

@synthesize carousel;
@synthesize navItem;
@synthesize orientationBarItem;
@synthesize wrapBarItem;
@synthesize wrap;
@synthesize items;


- (void)setUp {
    //set up data
    self.wrap = NO;
    self.items = [NSMutableArray array];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setUp];
    }
    return self;
}

- (void)dealloc {
    carousel.delegate = nil;
    carousel.dataSource = nil;
}


#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    photoDictionary = [NSMutableDictionary dictionary];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeInvertedTimeMachine;
    self.carousel.ignorePerpendicularSwipes = YES;
    UIImageView *roundedView = emptyHolderView.subviews[0];
    roundedView.image = [roundedView.image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFlags:) name:@"updateFlags" object:nil];
    
    
    [applicationsButton addTarget:self action:@selector(openApplications) forControlEvents:UIControlEventTouchUpInside];
    counterView.hidden = YES;
    counterView.alpha = 0.0;
    
    spinner.hidesWhenStopped = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount) name:@"updateUnreadCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForShowing) name:@"checkForShowing" object:nil];
    
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        roundedView.frameY = 43;
        roundedView.frameHeight = self.view.frameHeight - roundedView.frameY - 50;
        logoImageView.frameY += 8;
        messagesButton.frameY += 8;
        emptyHolderView.frameY += 20;
        downloadIcon.frameY += 45;
        
    } else if ([UIScreen mainScreen].bounds.size.height == 667){
        emptyHolderView.frame = CGRectMake(0, 0, 317, 550);
        emptyHolderView.center = self.view.center;
        emptyHolderView.frameY += 10;
        downloadIcon.frameY += 40;
    } else if ([UIScreen mainScreen].bounds.size.height == 736){
        emptyHolderView.frame = CGRectMake(0, 0, 342, 600);
        emptyHolderView.center = self.view.center;
        emptyHolderView.frameY += 10;
        downloadIcon.frameY += 42;
    } else {

    }

    [self loadJobs];
}

- (void)updateFlags:(NSNotification *)notification {
    NSDictionary *flags = notification.object;
    NSString *jobId = notification.userInfo[@"id"];
    NSMutableArray *mutableItems = [self.items mutableCopy];
    for (NSInteger i = 0; i < mutableItems.count; i++) {
        NSMutableDictionary *dict = [mutableItems[i] mutableCopy];
        if ([dict[@"id"] isEqualToString:jobId]) {
            dict[@"flags"] = flags;
            [mutableItems replaceObjectAtIndex:i withObject:dict];
            self.items = mutableItems;
            break;
        }
    }
    
}

- (void)checkForShowing {
    finishedImages ++;
    if (finishedImages == MIN(3, totalImagesCount)) {
        [spinner stopAnimating];
        NSLog(@"show");
        self.carousel.hidden = NO;
        finishedImages = 0;
    }
}

- (void)detailPressed {
    NSInteger index = carousel.currentItemIndex;
    
    [self performSegueWithIdentifier:@"detail" sender:self.items[index]];
}


- (void)openApplications {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentApplications" object:nil];
}

- (IBAction)openChat:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentMessages" object:nil];
}

- (void)updateUnreadCount {
    unreadCount = Server.unreadCount;
    [self configureCounterView];
//    messagesButton
}

- (void)configureCounterView {
    UILabel *countLabel = counterView.subviews[0];
    countLabel.text = [NSString stringWithFormat:@"%d", unreadCount.integerValue];
    [countLabel sizeToFit];
    counterView.frameWidth = 14 + countLabel.frameWidth;
    countLabel.center = CGPointMake(counterView.frameWidth / 2.0, counterView.frameHeight / 2.0);
    messagesButton.hidden = !self.items.count;
    
    counterView.hidden = !(unreadCount.integerValue && !messagesButton.hidden);
    
    if (self.view.frameWidth - 8 < counterView.frameRight) {
        counterView.frameRight = self.view.frameWidth - 3;
    }
}


- (void)loadJobs {
    [spinner startAnimating];
    messagesButton.hidden = !self.items.count;
    counterView.hidden = !self.items.count;
    emptyHolderView.hidden = YES;
    applicationsButton.hidden = YES;
    self.carousel.hidden = YES;
    [Server callFunctionInBackground:@"jobs" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count) {
            [self.items removeAllObjects];
            [self.items addObjectsFromArray:receivedItems];
            
            totalImagesCount = 0;
                for (NSDictionary *dict in self.items) {
                    if ([dict[@"company"][@"photoUrl"] length]) {
                        totalImagesCount ++;
                    }
                }
        
            
        } else {
            [self carouselDidScroll:carousel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [self updateUnreadCount];
            [carousel reloadData];
            emptyHolderView.hidden = NO;
            applicationsButton.hidden = NO;
        });

    }];
}

- (void)updateImage:(UIImage *)image forJobId:(NSString *)jobId {
    if (image) {
        photoDictionary[jobId] = image;
    }
    [presentedDetail updateImage:photoDictionary[jobId]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setNavigationBarHidden:YES animated:animated];
//        [Server.firstNavVC setNavigationBarHidden:YES animated:YES];
//    });
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
    self.navItem = nil;
    self.orientationBarItem = nil;
    self.wrapBarItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (IBAction)toggleOrientation {
    //carousel orientation can be animated
    [UIView beginAnimations:nil context:nil];
    self.carousel.vertical = !self.carousel.vertical;
    [UIView commitAnimations];
    
    //update button
    self.orientationBarItem.title = self.carousel.vertical? @"Vertical": @"Horizontal";
}

- (IBAction)toggleWrap
{
//    self.wrap = !self.wrap;
    self.wrapBarItem.title = self.wrap? @"Wrap: ON": @"Wrap: OFF";
    [self.carousel reloadData];
}

- (IBAction)insertItem
{
    NSInteger index = MAX(0, self.carousel.currentItemIndex);
    [self.items insertObject:@(self.carousel.numberOfItems) atIndex:(NSUInteger)index];
    [self.carousel insertItemAtIndex:index animated:YES];
}

- (IBAction)removeItem
{
    if (self.carousel.numberOfItems > 0)
    {
        NSInteger index = self.carousel.currentItemIndex;
        [self.items removeObjectAtIndex:(NSUInteger)index];
        [self.carousel removeItemAtIndex:index animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSMutableDictionary *)sender {
    if ([segue.identifier isEqualToString:@"detail"]) {
        DetailVC *detailVC = ((UINavigationController *)segue.destinationViewController).viewControllers[0];
        presentedDetail = detailVC;
        [presentedDetail updateImage:photoDictionary[sender[@"id"]]];
        [detailVC setData:sender];
    } else if ([segue.identifier isEqualToString:@"openChat"]) {
        NSInteger index = carousel.currentItemIndex;
        NSNumber *item = (self.items)[(NSUInteger)index];
        NSLog(@"Tapped view number: %@", item);
        ChatVC *chat = segue.destinationViewController;
        chat.dataDictionary = self.items[index];
        chat.fromDetail = YES;
    }
}



#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return (NSInteger)[self.items count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(CardView *)view {
    if (view == nil) {
        view = [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil][0];
        view.delegate = self;
        [self configureCardView:view];

    }
    
    [view configureViewWithJob:self.items[index]];
    
    return view;
}

- (void)configureCardView:(CardView *)view {
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        //4s
        view.frameWidth = 267;
        view.frameY += 23;
        view.frameHeight = 390;
        view.infoTextView.frameHeight -= 37;
    } else if ([UIScreen mainScreen].bounds.size.height == 667) {
        //6
        view.frameHeight = 550;
        view.frameWidth += 50;

    } else if ([UIScreen mainScreen].bounds.size.height == 736) {
        //6+
        view.frameHeight = 600;
        view.frameWidth += 75;
    } else {
        //5-5s
        view.frameWidth = 267;
        view.frameY -= 3;
        view.frameHeight = 456;
    }
    
    view.photoImageView.frameHeight = view.photoImageView.frameWidth / 1.62;
    view.pinIcon.frameY = view.photoImageView.frameBottom + 8;
    view.locationLabel.frameY = view.photoImageView.frameBottom + 6;
    view.lineView.frameY = view.locationLabel.frameBottom + 2;
    view.lineView.frameHeight = 1.5;
    
    view.infoTextView.frameY = view.locationLabel.frameY + 20;
    view.infoTextView.frameHeight = view.codeLabel.frameBottom  - view.infoTextView.frameY;
    
    view.contentWebView.frame = view.infoTextView.frame;
    [view.infoTextView removeFromSuperview];
    
//    1.62
}

- (UIImage *)renderedImageFromView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    [view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return copied;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel {
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(CardView *)view {
    return view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 0.75f;
        }
        case iCarouselOptionFadeMax:
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:

        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        {
            if (option == iCarouselOptionFadeRange) {
                return 1;
            }
        }
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            if (option == iCarouselOptionVisibleItems) {
                return 5;
            }
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carouselDidScroll:(iCarousel *)_carousel {
    CGFloat alpha = self.items.count - _carousel.scrollOffset;
    if (!self.items.count) alpha = 0;
    emptyHolderView.alpha = 1 - alpha;
    applicationsButton.alpha  = 1 - alpha;
    messagesButton.alpha = alpha;
    counterView.alpha = alpha;
    if (!alpha) {
        [self.view bringSubviewToFront:applicationsButton];
    } else {
        [self.view insertSubview:applicationsButton aboveSubview:emptyHolderView];
    }
}

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSNumber *item = (self.items)[(NSUInteger)index];
    NSLog(@"Tapped view number: %@", item);
    
    [self performSegueWithIdentifier:@"detail" sender:self.items[index]];
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    NSLog(@"Index: %@", @(self.carousel.currentItemIndex));
    
    if (self.carousel.currentItemIndex >= 0) {
        [Server callFunctionInBackground:@"markJobAsSeen" withParameters:@{@"userId" : Server.userInfoDictionary[@"userId"], @"jobId" : self.items[self.carousel.currentItemIndex][@"id"]
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
}


@end
