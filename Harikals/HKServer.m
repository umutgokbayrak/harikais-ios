//
//  HKServer.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "HKServer.h"
#import <AFNetworking.h>
#import <IOSLinkedInAPI/LIALinkedInApplication.h>
#import <LIALinkedInHttpClient.h>
#define BASE_SARVER_URL @"https://api.parse.com/1/functions/"

static HKServer *sharedServer = nil;

@interface HKServer ()
@end

@implementation HKServer {
    AFHTTPRequestOperationManager *manager;
    dispatch_queue_t background;
    NSUserDefaults *userDefaults;
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
        
    }
    
    return self;
}


- (void)callFunctionInBackground:(NSString *)function  withParameters:(NSDictionary *)parameters block:(CompletionBlock)block {
    NSString *serverRequestString = BASE_SARVER_URL;
    NSString *finalString  = [NSString stringWithFormat:@"%@%@", serverRequestString, function];
    [manager POST:finalString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (responseObject[@"result"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block(responseObject[@"result"], nil);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil, error);
    }];
    
}

- (void)serverUploadPicture:(UIImage *)picture userId:(NSString *)userId success:(void(^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure {
    UIImage *photo = picture;
//    NSData *imageData = UIImagePNGRepresentation(photo);
    
    NSString *finalString  = [NSString stringWithFormat:@"%@%@", BASE_SARVER_URL, @"uploadPhoto"];
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:finalString parameters:@{@"userId" : userId} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(photo, 1.0);
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
    } error:nil];

    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        success(responseObject);
        NSLog(@"upload ok");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        NSLog(@"%@", error);
    }];
    [operation start];
}

- (void)getProfileIDWithAccessToken:(NSString *)accessToken block:(PFStringResultBlock)block {
    [(LIALinkedInHttpClient *)self.linkedInHttpClient GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *profileID = nil;
        NSString *profileURL = responseObject[@"siteStandardProfileRequest"][@"url"];
        if (profileURL)
        {
            NSString *params = [[profileURL componentsSeparatedByString:@"?"] lastObject];
            if (params)
            {
                for (NSString *param in [params componentsSeparatedByString:@"&"])
                {
                    NSArray *keyVal = [param componentsSeparatedByString:@"="];
                    if (keyVal.count > 1)
                    {
                        if ([keyVal[0] isEqualToString:@"id"])
                        {
                            profileID = keyVal[1];
                            break;
                        }
                    }
                }
            }
        }
        if (profileID)
        {
            if (block)
            {
                block(profileID, nil);
            }
        }
        else if (block)
        {
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



@end
