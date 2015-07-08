//
//  DropdownModel.h
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/25/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DropMenuDelegate <NSObject>

@optional
- (void)didSelectOption:(NSString *)optionString optionsArray:(NSMutableArray *)array;

@end


@interface DropdownModel : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) NSMutableArray *dataArray;
@property (nonatomic, weak) id  <DropMenuDelegate> delegate;


@end
