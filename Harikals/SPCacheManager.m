//
//  SPCaheManager.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/4/15.
//  Copyright (c) 2015 Inomma. All rights reserved.
//

#import "SPCacheManager.h"
#import <MagicalRecord.h>
#import <AFNetworking.h>
#import "CacheInfo.h"



@interface  SPCacheManager () {

    dispatch_queue_t cacheBackground;

    NSMutableDictionary *fastCache;
    NSFileManager *fileManager;
    NSManagedObjectContext *localContext;
}

@end


static SPCacheManager *manager = nil;

@implementation SPCacheManager


+ (SPCacheManager *)sharedManager {
    if (!manager) {
        manager = [[SPCacheManager alloc] init];
    }
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        fileManager = [NSFileManager defaultManager];
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"imagesCache.sqlite"];
        [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelError];
        localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
        cacheBackground = dispatch_queue_create("com.harikais.cachebackground", NULL);
        
        fastCache = [[NSMutableDictionary alloc] init];
        [self loadFastCache:^{
            //TODO:Remove NSLog
            NSLog(@"cahe loaded");
            
            [self cleanExpired];
        }];

    }
    return self;
}

- (void)cleanExpired {
    NSDate *date = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expires < %@", date];
    NSArray *cacheInfos = [CacheInfo MR_findAllWithPredicate:predicate inContext:localContext];
    if (cacheInfos.count) {
        for (int i = 0; i < cacheInfos.count; i++) {
            CacheInfo *imageDataFounded = cacheInfos[i];
            if (imageDataFounded) {
                if ([imageDataFounded.expires compare:date] == NSOrderedAscending) {
                    NSString *storePath = [[self storeDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@", imageDataFounded.path]];
                    if ([fileManager fileExistsAtPath:storePath]) {
                        NSError *error;
                        BOOL removed = [fileManager removeItemAtPath:storePath error:&error];
                        if (removed) {
                            [imageDataFounded MR_deleteEntity];
                        }
                    }
                }
            }
        }
    }
}


- (void)loadFastCache:(void(^)())finished {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"fast"];
    NSArray *cacheInfos = [CacheInfo MR_findAllWithPredicate:predicate inContext:localContext];
    NSDate *date = [NSDate date];
    dispatch_async(cacheBackground, ^{
        for (int i = 0; i < cacheInfos.count; i++) {
            CacheInfo *imageDataFounded = cacheInfos[i];
            if (imageDataFounded) {
                NSString *storePath = [[self storeDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@", imageDataFounded.path]];
                UIImage *image = [UIImage imageWithContentsOfFile:storePath];
                if (image && [imageDataFounded.expires compare:date] == NSOrderedDescending) {
                    [fastCache setObject:image forKey:imageDataFounded.path];
                }
            }
        }
        finished();
    
    });
}


- (void)downloadImage:(NSString *)imagePath expires:(NSDate *)expires toFastCache:(BOOL)toFast success:(void(^)(UIImage *image, NSError *error))success {
    __block BOOL isToDownload = NO;
    
    NSString *cuttedPath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"1"];
//    cuttedPath = [cuttedPath stringByReplacingOccurrencesOfString:@"?updated=" withString:@""];
    UIImage  *fastImage = fastCache[cuttedPath];

    void (__block ^download)() = ^{

        NSString *storePath = [[self storeDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@", cuttedPath]];
        
        if (isToDownload) {
            if (fastImage) {
                success(fastImage, nil);
                return;
            }
//            NSArray *componets = [cuttedPath componentsSeparatedByString:@"/"];
            NSString *tmpPath = [NSString stringWithFormat:@"%@/images", [self storeDirectory]];
            
            if (![fileManager fileExistsAtPath:storePath]) {
                [fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:NO attributes:nil error:nil];
            } else {
                NSError *error;
                BOOL removed = [fileManager removeItemAtPath:storePath error:&error];
                if (!removed) {
                    NSLog(@"Not removed from cache :%@", error);
                }
            }
            
//            for (int i = 0; i < componets.count - 1; i++) {
//                tmpPath = [NSString stringWithFormat:@"%@/%@", tmpPath, componets[i]];
//                
//                if (![fileManager fileExistsAtPath:tmpPath])
//                    [fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:NO attributes:nil error:nil];
//            }
            
            NSURL *url = [NSURL URLWithString:imagePath];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionQueue:cacheBackground];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIImage *image = [UIImage imageWithData:responseObject scale:[UIScreen mainScreen].scale];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *dataImage = UIImageJPEGRepresentation(image, 100);
                    [dataImage writeToFile:storePath atomically:NO];
                });
                if (![fastCache[cuttedPath] isEqual:image]) {
                    [fastCache setObject:image forKey:cuttedPath];
                }
                if (success) success(image, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) success(nil,error);
                });
            }];

            [operation start];
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:storePath];
            if (![fastCache[cuttedPath] isEqual:image]) {
                [fastCache setObject:image forKey:cuttedPath];
            }
            success(image, nil);
        }
    };
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"path ==[c] %@", cuttedPath];
    CacheInfo *imageDataFounded = [CacheInfo MR_findFirstWithPredicate:predicate inContext:localContext];
    NSString *storePath = [[self storeDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@", cuttedPath]];
    
    if (imageDataFounded) {
        if (imageDataFounded.expires && [imageDataFounded.expires compare:[NSDate date]] == NSOrderedAscending){
            
            
            if (!expires)  {
                imageDataFounded.expires = [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 3];
            } else {
                imageDataFounded.expires = expires;
            }
            if (toFast) {
                imageDataFounded.name = @"fast";
            }
            isToDownload = YES;
            
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    download();
                });
            }];
            
        } else if ([fileManager fileExistsAtPath:storePath]) {
            isToDownload = NO;
            
            if (!expires)  {
                imageDataFounded.expires = [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 3];
            } else {
                imageDataFounded.expires = expires;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                download();
            });
            [localContext MR_saveToPersistentStoreAndWait];
        } else {
            isToDownload = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                download();
            });
        }
        
    } else if (!imageDataFounded) {
        CacheInfo *newImageData = [CacheInfo MR_createEntityInContext:localContext];
        newImageData.path = cuttedPath;
        if (!expires)  {
            newImageData.expires = [[NSDate date] dateByAddingTimeInterval:3600 * 24 * 3];
        } else {
            newImageData.expires = expires;
        }
        if (toFast) {
            newImageData.name = @"fast";
        }
        isToDownload = YES;
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                download();
            });
        }];
        
    } else {
        isToDownload = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            download();
        });
    }
    
}

- (NSString *)storeDirectory {
    NSString *libraryPath = [NSString stringWithFormat:@"%@/Caches/", [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]];
    
    return libraryPath;
}

- (void)cleanUp {
    [MagicalRecord cleanUp];
}

- (id)objectForKey:(NSString *)key {
    return fastCache[key];
}

- (void)setObject:(id)anObject ForKey:(NSString *)key {
    fastCache[key] = anObject;
}

@end
