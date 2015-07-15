//
//  FillVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "FillVC.h"
#import "UIMonthYearPicker.h"

@interface FillVC () <UITextFieldDelegate, UIMonthYearPickerDelegate> {
    
    __weak IBOutlet UILabel *isCurrentLabel;
    
    __weak IBOutlet UITextField *secondField;
    __weak IBOutlet UITextField *firstField;
    __weak IBOutlet UITextField *thirdField;
    
    __weak IBOutlet UISwitch *isCurrentSwitch;
    __weak IBOutlet UITextField *startPeriodField;
    
    __weak IBOutlet UITextField *endPeriodField;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatter2;
    
    __weak IBOutlet NSLayoutConstraint *scrollViewBottom;
    
    NSDate *date1;
    NSDate *date2;
    
}

@end

@implementation FillVC

- (void)viewDidLoad {
    [super viewDidLoad];
    secondField.delegate = self;
    firstField.delegate = self;
    thirdField.delegate  = self;
    dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM YYYY"];
    
    dateFormatter2  = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"YYYY-MM"];
    
    startPeriodField.delegate = self;
    endPeriodField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self loadInputViews];
    
    [self fillFields];
}

- (void)fillFields {
    if (self.receivedData) {
        if (self.view.tag == 0 ) {
            firstField.text = self.receivedData[@"school"];
            secondField.text = self.receivedData[@"degree"];
            thirdField.text = self.receivedData[@"fieldOfStudy"];
            
            
        } else {
            firstField.text = self.receivedData[@"title"];
            secondField.text = self.receivedData[@"name"];
        }
        
        isCurrentSwitch.on = [self.receivedData[@"isCurrent"] isEqualToString:@"true"];
        date1 = [dateFormatter2 dateFromString:self.receivedData[@"dateEnter"]];
        date2 = [dateFormatter2 dateFromString:self.receivedData[@"dateExit"]];
        
        startPeriodField.text = [dateFormatter stringFromDate:date1];
        endPeriodField.text = [dateFormatter stringFromDate:date2];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Not all fields are filled!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (void)updateWithDataDict:(NSDictionary *)dataDict {
    if (self.view.tag == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateEdu" object:dataDict userInfo:@{@"index" : @(self.index)}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCompany" object:dataDict userInfo:@{@"index" : @(self.index)}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if (self.view.tag == 1) {
        if (firstField.text.length && secondField.text.length  && startPeriodField.text.length && endPeriodField.text.length) {
            NSDictionary *data = @{@"title" : firstField.text,
                                   @"name" : secondField.text,
                                   @"isCurrent" : isCurrentSwitch.on ? @"true" : @"false",
                                   @"dateEnter" : [dateFormatter2 stringFromDate:date1],
                                   @"dateExit" : [dateFormatter2 stringFromDate:date2]
                                   };
            [self updateWithDataDict:data];
        } else {
            [self showAlert];
        }
    } else {
        if (firstField.text.length && secondField.text.length && thirdField.text.length && startPeriodField.text.length && endPeriodField.text.length) {
            NSDictionary *data = @{@"school" : firstField.text,
                                   @"degree" : secondField.text,
                                   @"fieldOfStudy" : thirdField.text,
                                   @"isCurrent" : isCurrentSwitch.on ? @"true" : @"false",
                                   @"dateEnter" : [dateFormatter2 stringFromDate:date1],
                                   @"dateExit" : [dateFormatter2 stringFromDate:date2]
                                   };
            [self updateWithDataDict:data];
        } else {
            [self showAlert];
        }
    }

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)loadInputViews {
    UIMonthYearPicker *datePicker  = [[UIMonthYearPicker alloc] init];
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:200000];
    datePicker.maximumDate = [NSDate date];
    datePicker.date = [NSDate dateWithTimeIntervalSince1970:200000];

    startPeriodField.inputView = datePicker;
    endPeriodField.inputView = datePicker;
    datePicker._delegate = self;
    [datePicker reloadAllComponents];
}

- (void)pickerView:(UIPickerView *)pickerView didChangeDate:(NSDate *)newDate {
    if (startPeriodField.isFirstResponder) {
        startPeriodField.text = [dateFormatter stringFromDate:newDate];
        date1 = newDate;
    } else if (endPeriodField.isFirstResponder) {
        endPeriodField.text = [dateFormatter stringFromDate:newDate];
        date2 = newDate;
    }
}

- (void)keyboardWillChageFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    scrollViewBottom.constant = self.view.frame.size.height - keyboardEndFrame.origin.y;
    
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}


@end
