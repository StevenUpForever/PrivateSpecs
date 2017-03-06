//
//  ResetPasswordViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/10/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "DesignableUIKit.h"
#import "FunctionAPI.h"
#import "UIKitCategories.h"

@interface ResetPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *currentPwTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *TheNewPwTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *confirmPwTextField;

@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmPwTextField.delegate = self;
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"Resetting";
    [self.view addSubview:self.indicator];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingMainView)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(CustomButton *)sender {
    
    if (self.currentPwTextField.text.length == 0) {
        [self showMissedInformationAlertController:@"Please fill out your current password"];
    } else if (self.TheNewPwTextField.text.length == 0) {
        [self showMissedInformationAlertController:@"Please fill out your new password"];
    } else if (self.confirmPwTextField.text.length == 0) {
        [self showMissedInformationAlertController:@"Please fill out your confirm password"];
    } else if (![self.TheNewPwTextField.text isEqualToString:self.confirmPwTextField.text]) {
        [self showMissedInformationAlertController:@"Password and confirm doesn't match"];
    } else {
        [self.indicator show:YES];
        
        [FunctionAPI resetPassword:self.currentPwTextField.text newPassword:self.TheNewPwTextField.text successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [CustomAlertController showCancelAlertControllerWithTitle:nil message:@"Reset password successfully" action:nil target:self];
                [self.indicator hide:YES];
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [CustomAlertController showCancelAlertControllerWithTitle:@"Reset failed" message:errorString action:nil target:self];
            });
        }];
    }
    
}

#pragma mark - private method

- (void)showMissedInformationAlertController: (NSString *)errorMessage {
    [CustomAlertController showCancelAlertControllerWithTitle:@"Missed information" message:errorMessage action:nil target:self];
}

- (void)endEditingMainView {
    [self.view endEditing:YES];
}

#pragma mark - textField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.confirmPwTextField) {
        if (![textField.text isEqualToString:self.TheNewPwTextField.text]) {
            textField.layer.borderColor = [UIColor DwinkRed].CGColor;
        } else {
            textField.layer.borderColor = [UIColor DwinkGrey].CGColor;
        }
    }
}


@end
