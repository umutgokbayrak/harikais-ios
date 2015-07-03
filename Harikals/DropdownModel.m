//
//  DropdownModel.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 6/25/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "DropdownModel.h"

@implementation DropdownModel

//-------------------------------------------------------------------------------------------------------------
#pragma mark - UITableView Data Source Methods
//-------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropCell"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

@end
