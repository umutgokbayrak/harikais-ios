//
//  HKServer.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

@import SystemConfiguration;

#import "Reachability.h"
#import "lelib.h"
#import "HKServer.h"
#import <AFNetworking.h>
#import <IOSLinkedInAPI/LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>
#import "AppDelegate.h"
#import "AlertVC.h"

#define BASE_SERVER_URL @"http://test.harikais.com:8080/"

static HKServer *sharedServer = nil;

@interface HKServer () {
    LELog* log;
        Reachability *reachability;
    BOOL justShown;
}
@end

@implementation HKServer {
    AFHTTPRequestOperationManager *manager;
    dispatch_queue_t background;
    NSUserDefaults *userDefaults;
}

- (NSDictionary *)userInfoDictionary {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userData"];
}

//-------------------------------------------------------------------------------------------------------------
#pragma mark - Runtime Initialization Methods
//-------------------------------------------------------------------------------------------------------------
+ (HKServer *)sharedServer {
    static dispatch_once_t onceRuntimeData;
    dispatch_once(&onceRuntimeData, ^{
        sharedServer = [[super alloc] initUniqueInstance];
    });
    
    return sharedServer;
}

- (void)showAlertWithText:(NSString *)text closeButton:(NSString *)closeButton {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AlertVC *alertVC = (AlertVC *)appdelegate.alertWindow.rootViewController;
    alertVC.view.hidden = NO;
    alertVC.webHolder.hidden = YES;
    alertVC.mainAlertHolder.hidden = NO;
    alertVC.favouriteAlertHolder.hidden =YES;
    alertVC.mainLabel.text = text;
    [alertVC.closeButton setTitle:closeButton forState:UIControlStateNormal];
    
    
    [appdelegate.alertWindow makeKeyAndVisible];

}



- (void)showFavouriteAlertWithTitle:(NSString *)title text:(NSString *)text {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AlertVC *alertVC = (AlertVC *)appdelegate.alertWindow.rootViewController;
    alertVC.view.hidden = NO;
    alertVC.webHolder.hidden = YES;
    alertVC.secondaryText.text = text;
    alertVC.titleLabel.text = title;
    alertVC.mainAlertHolder.hidden = YES;
    alertVC.favouriteAlertHolder.hidden = NO;
    appdelegate.alertWindow.windowLevel = UIWindowLevelAlert;
    [appdelegate.alertWindow makeKeyAndVisible];
}


- (void)showWebAlertWithText:(NSString *)text {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AlertVC *alertVC = (AlertVC *)appdelegate.alertWindow.rootViewController;
    alertVC.view.hidden = NO;
    alertVC.webHolder.hidden = NO;
    [alertVC.webView loadHTMLString:text baseURL:nil];
    alertVC.mainAlertHolder.hidden = YES;
    alertVC.favouriteAlertHolder.hidden = YES;
    appdelegate.alertWindow.windowLevel = UIWindowLevelAlert;
    [appdelegate.alertWindow makeKeyAndVisible];
}


- (instancetype)initUniqueInstance {
    if (self = [super init]) {
        background = dispatch_queue_create("com.harikais.serverbackground", NULL);
        manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager setCompletionQueue:background];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"7EqNvrRwIHC2CP34qAgVJTCCmmReT5gnZdZM5zYP" forHTTPHeaderField:@"X-Parse-Application-Id"];
        [manager.requestSerializer setValue:@"f8LCXQKaAEzbsStXURKlbIWaPS8yj43Gx7uNgCsq" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
        
        reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        log = [LELog sharedInstance];
        log.token = @"956a19d4-3057-44ab-9608-1245bfff6db5";

    }
    
    return self;
}

- (void) handleNetworkChange:(NSNotification *)notice {
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) {NSLog(@"no");}
    else if (remoteHostStatus == ReachableViaWiFi) {NSLog(@"wifi"); }
    else if (remoteHostStatus == ReachableViaWWAN) {NSLog(@"cell"); }
}

- (void)showNoInternetAlert {
    if (!justShown) {
        justShown = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bağlantı hatası." message:@"Lütfen Internet bağlantınızı kontrol ediniz" delegate:nil cancelButtonTitle:@"Kapat" otherButtonTitles:nil];
        [alertView show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            justShown = NO;
        });
    }
}

- (void)callFunctionInBackground:(NSString *)function  withParameters:(NSDictionary *)parameters block:(CompletionBlock)block {
    NSString *serverRequestString = BASE_SERVER_URL;
    NSString *finalString  = [NSString stringWithFormat:@"%@%@", serverRequestString, function];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if ([function isEqualToString:@"autocompleteLocation"] ||
        [function isEqualToString:@"autocompleteIndustries"] ||
        [function isEqualToString:@"autocompleteSkills"]) {
        manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    } else {
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    
    if (remoteHostStatus == NotReachable) {
        [self showNoInternetAlert];
        if (block) block(nil, [[NSError alloc] init]);
    } else {
        [manager POST:finalString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            if (responseObject[@"result"]) {
                if ([responseObject[@"result"] isKindOfClass:[NSDictionary class]] && responseObject[@"result"][@"result"] && [responseObject[@"result"][@"result"] isKindOfClass:[NSNumber class]]) {
                    if ([responseObject[@"result"][@"result"] integerValue] != 0) {
                        [log log:[NSString stringWithFormat:@"Function: %@, error msg: %@", function, responseObject[@"result"][@"msg"]]];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block(responseObject[@"result"], nil);
                });
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) block(nil, error);
        }];
    }
    
}

- (void)serverUploadPicture:(UIImage *)picture userId:(NSString *)userId success:(void(^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure {
    UIImage *photo = picture;
    
    NSString *finalString  = [NSString stringWithFormat:@"%@%@", BASE_SERVER_URL, @"uploadPhoto"];
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:finalString parameters:@{@"userId" : userId} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(photo, 1.0);
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } error:nil];

//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [log log:[NSString stringWithFormat:@"Function: uploadPhoto, error description: %@", error.description]];
        
        failure(error);
    }];
    [operation start];
}

- (void)getProfileIDWithAccessToken:(NSString *)accessToken block:(PFStringResultBlock)block {
    [(LIALinkedInHttpClient *)self.linkedInHttpClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,location,industry,num-connections-capped,num-connections,picture-url,specialties,positions,public-profile-url,summary)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *profile = responseObject;
        if (profile) {
            if (block) {
                block(profile, nil);
            }
        }
        else if (block) {
            //TODO:Remove NSLog
            NSLog(@"%@", @"LinkedIn Id Missing");
            block(nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block)
        {
            block(nil, error);
        }
    }];
}


- (void)getAvaURL:(NSString *)userID token:(NSString *)accessToken block:(PFStringResultBlock)block {
    [(LIALinkedInHttpClient *)self.linkedInHttpClient GET:[NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~:(picture-url)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *profile = responseObject;
        if (profile) {
            if (block) {
                block(profile, nil);
            }
        } else if (block) {
            //TODO:Remove NSLog
            NSLog(@"%@", @"Ava url Missing");
            block(nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block)
        {
            block(nil, error);
        }
    }];
}



@end
