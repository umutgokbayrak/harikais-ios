//
//  HKServer.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define Server			[HKServer sharedServer]
typedef void (^CompletionBlock)(id object, NSError * error);
typedef void (^PFStringResultBlock)(NSString * string, NSError * error);


@interface HKServer : NSObject

@property (nonatomic, strong) NSDictionary *configDictionary;
@property (nonatomic, strong) NSDictionary *userInfoDictionary;
@property (nonatomic, weak) UINavigationController *firstNavVC;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) id linkedInHttpClient;

+ (instancetype)sharedServer;


- (void)callFunctionInBackground:(NSString *)function
                  withParameters:(NSDictionary *)parameters
                           block:(CompletionBlock)block;


- (void)serverUploadPicture:(UIImage *)picture userId:(NSString *)userId success:(void(^)(NSDictionary *responseObject))success failure:(void(^)(NSError *error))failure;



@end
