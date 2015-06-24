//
//  SPCaheManager.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/4/15.
//  Copyright (c) 2015 Inomma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SPCacheManager : NSObject

+ (SPCacheManager *)sharedManager;

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)anObject ForKey:(NSString *)key;


- (void)downloadImage:(NSString *)imagePath expires:(NSDate *)expires toFastCache:(BOOL)toFast success:(void(^)(UIImage *image, NSError *error))success ;

- (void)cleanUp;

@end
