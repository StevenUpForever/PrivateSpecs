//
//  findEmailViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "findEmailViewController.h"
#import "LoginAPI.h"

@interface findEmailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation findEmailViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"Sending email";
    [self.view addSubview:self.indicator];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endMainViewEditing)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)resetButton {
    [self.indicator show:YES];
    [self.emailTextField resignFirstResponder];
    [LoginAPI resetPasswordByEmail:self.emailTextField.text successHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:@"We have sent you the reset email, please check your mailbox" message:nil action:^(UIAlertAction *action) {
                    [self.emailTextField resignFirstResponder];
                    [self dismissViewControllerAnimated:YES completion:nil];
            } target:self];
        });
    } error:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}

#pragma mark - custom Selectors

- (void)endMainViewEditing {
    [self.view endEditing:YES];
}


@end
