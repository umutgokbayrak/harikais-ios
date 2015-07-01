//
//  HKServer.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "HKServer.h"
#import <AFNetworking.h>




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
    NSString *serverRequestString = @"https://api.parse.com/1/functions/";
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


@end
