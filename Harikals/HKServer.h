//
//  HKServer.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Server			[HKServer sharedServer]
typedef void (^CompletionBlock)(id object, NSError * error);

@interface HKServer : NSObject

+ (instancetype)sharedServer;


- (void)callFunctionInBackground:(NSString *)function
                  withParameters:(NSDictionary *)parameters
                           block:(CompletionBlock)block;

@end
