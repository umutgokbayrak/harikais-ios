//
//  FillVC.m
//  Harikals
//
//  Created by Nikolay Tabunchenko on 7/7/15.
//  Copyright (c) 2015 tabunchenko. All rights reserved.
//

#import "FillVC.h"
#import "UIMonthYearPicker.h"

@interface FillVC () <UITextFieldDelegate, UIMonthYearPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
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
    
    NSArray *eduOptions;
    
    
    NSDate *date1;
    NSDate *date2;
    
    CGFloat baseHight;
    
    UIPickerView *eduPickerView;
    __weak IBOutlet NSLayoutConstraint *holderHightConstrait;
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
    
    
    eduPickerView = [[UIPickerView alloc] init];
    eduPickerView.dataSource = self;
    eduPickerView.delegate = self;
    
    eduOptions = @[@"B.A.", @"B.S.", @"J.D.", @"M.A.", @"M.B.A.", @"M.D.", @"M.S.", @"PhD", @"Hiçbiri"];
    
    [eduPickerView reloadAllComponents];

    isCurrentSwitch.on = NO;

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [isCurrentSwitch addTarget:self action:@selector(adjustForCurrent) forControlEvents:UIControlEventValueChanged];
    
    startPeriodField.delegate = self;
    endPeriodField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self loadInputViews];
    
//            if (self.view.tag == 0 ) {
//                baseHight = 315;
//                secondField.inputView = eduPickerView;
//            } else {
                baseHight = 264;
//            }
    
    [self fillFields];
}

- (void)fillFields {
    if (self.receivedData) {
        if (self.view.tag == 0 ) {
            
            firstField.text = self.receivedData[@"school"];
//            secondField.text = self.receivedData[@"degree"];
            thirdField.text = self.receivedData[@"fieldOfStudy"];

            

        } else {
            firstField.text = self.receivedData[@"title"];
            secondField.text = self.receivedData[@"name"];

        }
        
        NSString *iscurrent = [NSString stringWithFormat:@"%@",  self.receivedData[@"isCurrent"]];
        
        isCurrentSwitch.on = ([iscurrent isEqualToString:@"true"] || [iscurrent isEqualToString:@"1"]);
        [self adjustForCurrentAnimated:NO];
        date1 = [dateFormatter2 dateFromString:self.receivedData[@"dateEnter"]];
        date2 = [dateFormatter2 dateFromString:self.receivedData[@"dateExit"]];
        
        startPeriodField.text = [dateFormatter stringFromDate:date1];
        endPeriodField.text = [dateFormatter stringFromDate:date2];
    }
}

- (void)adjustForCurrent {
    [self adjustForCurrentAnimated:YES];
}

- (void)adjustForCurrentAnimated:(BOOL)animated {
    holderHightConstrait.constant = isCurrentSwitch.on ? baseHight - 58 : baseHight;
    endPeriodField.enabled = !isCurrentSwitch.on;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}



-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return eduOptions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return eduOptions[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == eduPickerView) {
//        secondField.text = eduOptions[row];
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

- (NSInteger)lengthOfTrimmedString:(NSString *)string {
    return  [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length;
}

- (IBAction)save:(id)sender {
    
    if (self.view.tag == 1) {
        if ([self lengthOfTrimmedString:firstField.text] < 3) {
            [self showErrorAlert:@"Lütfen bu şirkette çalışırken taşıdığınız ünvanı paylaşır mısınız?"];
            return;
        }
        
        if ([self lengthOfTrimmedString:secondField.text] < 2) {
            [self showErrorAlert:@"Lütfen çalıştığınız şirketin adını paylaşır mısınız?"];
            return;
        }
    } else {
        
        if ([self lengthOfTrimmedString:firstField.text] < 3) {
            [self showErrorAlert:@"Lütfen eklemek istediğiniz okulun adını paylaşır mısınız?"];
            return;
        }
        
//        if ([self lengthOfTrimmedString:secondField.text] == 0 || ![eduOptions containsObject:secondField.text]) {
//            [self showErrorAlert:@"Bu okulda hangi dereceyi okudunuz/okuyor-sunuz?"];
//            return;
//        }
        
        if ([self lengthOfTrimmedString:thirdField.text] < 3) {
            [self showErrorAlert:@"Lütfen okulun bölümünü paylaşır mısınız?"];
            return;
        }
        
    }
    
    if ([self lengthOfTrimmedString:endPeriodField.text] == 0 && !isCurrentSwitch.on) {
        [self showErrorAlert:@"Bu işyerinden ne zaman ayrıldınız?"];
        return;
    }
    
    if (self.view.tag == 1) {
        if (firstField.text.length && secondField.text.length  && startPeriodField.text.length) {
            NSMutableDictionary *data = [@{@"title" : firstField.text,
                                   @"name" : secondField.text,
                                   @"isCurrent" : isCurrentSwitch.on ? @"true" : @"false",
                                   @"dateEnter" : [dateFormatter2 stringFromDate:date1]
                                   }mutableCopy];
            if (!isCurrentSwitch.on) {
                [data setObject:  [dateFormatter2 stringFromDate:date2] forKey:@"dateExit"];
            }
            [self updateWithDataDict:data];
        }
    } else {
        if (firstField.text.length && thirdField.text.length && startPeriodField.text.length) {
            NSMutableDictionary *data = [@{@"school" : firstField.text,
                                   @"fieldOfStudy" : thirdField.text,
                                   @"isCurrent" : isCurrentSwitch.on ? @"true" : @"false",
                                   @"dateEnter" : [dateFormatter2 stringFromDate:date1]
                                   } mutableCopy];
            
            if (!isCurrentSwitch.on) {
                [data setObject:  [dateFormatter2 stringFromDate:date2] forKey:@"dateExit"];
            }
            [self updateWithDataDict:data];
        }
    }

}

- (void)showErrorAlert:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustForCurrent];
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
    datePicker.date = [NSDate dateWithTimeIntervalSince1970:1104537600];

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
