//
//  PushNoAnimationSegue.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/18/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue
-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self   destinationViewController] animated:NO];
}
@end
