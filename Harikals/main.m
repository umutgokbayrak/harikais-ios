//
//  main.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "lecore.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        le_init();
        le_set_token("956a19d4-3057-44ab-9608-1245bfff6db5");
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
