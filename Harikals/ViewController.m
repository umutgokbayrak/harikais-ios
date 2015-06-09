//
//  ViewController.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <PFLinkedInUtils.h>

#import "ViewController.h"

@interface ViewController () {
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)loginPressed:(id)sender {
    [PFLinkedInUtils logInWithBlock:^(PFUser *user, NSError *error) {
        NSLog(@"User: %@, Error: %@", user, error);
        
        [PFLinkedInUtils.linkedInHttpClient GET:@"companies" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }];
}

@end
