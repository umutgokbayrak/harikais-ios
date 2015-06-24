//
//  CacheInfo.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/5/15.
//  Copyright (c) 2015 Inomma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CacheInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSDate * timestamp;

@end
