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


@interface CardsVC () <UIScrollViewDelegate, iCarouselDataSource, iCarouselDelegate, CardViewDelegate> {
    __weak IBOutlet UIView *emptyHolderView;
    NSMutableDictionary *photoDictionary;
    __weak IBOutlet UIImageView *logoImageView;
    
    __weak DetailVC *presentedDetail;
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
    
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        roundedView.frameY = 43;
        roundedView.frameHeight = self.view.frameHeight - roundedView.frameY - 50;
        logoImageView.frameY += 8;
    }
    [self loadJobs];
}

- (void)loadJobs {
    [PFCloud callFunctionInBackground:@"jobs" withParameters:@{@"userId" : [[PFUser currentUser][@"linkedInUser"] objectId]} block:^(NSArray *receivedItems, NSError *error) {
        if (receivedItems.count && !error) {
            [self.items removeAllObjects];
            [self.items addObjectsFromArray:receivedItems];
        } else {
            //TODO:Remove NSLog
            NSLog(@"JOBS ERROR %@", error);
        }
        
        [carousel reloadData];
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
    [self.navigationController setNavigationBarHidden:YES];
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
        if ([UIScreen mainScreen].bounds.size.height == 480) {

            view.frameY += 23;
            view.frameHeight = 390;
            view.infoTextView.frameHeight -= 37;
        } else {
            view.frameHeight = 450;
        }
        
        view.frameWidth = 267;
    } else {
        
    }
    [view configureViewWithJob:self.items[index]];
    
    return view;
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
    emptyHolderView.alpha = 1 - alpha;
    
}

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSNumber *item = (self.items)[(NSUInteger)index];
    NSLog(@"Tapped view number: %@", item);
    
    [self performSegueWithIdentifier:@"detail" sender:self.items[index]];
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
//    NSLog(@"Index: %@", @(self.carousel.currentItemIndex));
}


@end
