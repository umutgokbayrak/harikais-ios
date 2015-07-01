//
//  HKTextField.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/29/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "HKTextField.h"

@implementation HKTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

@end
