//
//  signUpViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/3.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "InfoSignUpViewController.h"
#import "PhotoSignUpViewController.h"
#import "SignUpAPI.h"
#import "FoundationCategories.h"
#import "UIKitCategories.h"

@interface InfoSignUpViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation InfoSignUpViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentViewGesture)];
    [self.contentView addGestureRecognizer:gesture];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"Waiting for sign up";
    [self.view addSubview:self.indicator];
    
    self.logoImageView.image = [self.logoImageView.image rotateImageToDirection:UIImageOrientationLeft];
    
    [self textFieldInitial];
}

- (void)textFieldInitial {
    [self.nameTextField setDwinkTextFieldStyleWithBorder];
    [self.userNameTextField setDwinkTextFieldStyleWithBorder];
    [self.emailTextField setDwinkTextFieldStyleWithBorder];
    [self.passwordTextField setDwinkTextFieldStyleWithBorder];
    self.passwordTextField.delegate = self;
    [self.confirmPasswordTextField setDwinkTextFieldStyleWithBorder];
    self.confirmPasswordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//Hide NavigationController when ViewController show

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - IBActions

- (IBAction)signUpButton {
    
    //If password doesn't match
    
    if (![self.confirmPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"Password Error"  message:@"Password doesn't match" action:nil target:self];
    } else {
        [self.indicator show:YES];
        [SignUpAPI creatNewUserInfoWithName:self.nameTextField.text username:self.userNameTextField.text email:self.emailTextField.text password:self.passwordTextField.text successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [self performSegueWithIdentifier:@"gotoAvatar" sender:self];
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [CustomAlertController showCancelAlertControllerWithTitle:@"Sign up error" message:errorString action:nil target:self];
            });
        }];
    }
}

- (void)contentViewGesture {
    [self.view endEditing:YES];
}

#pragma mark - selectors

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:UIKeyboardAnimationDurationUserInfoKey.doubleValue animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, kbSize.height + 10, 0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }];
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    //    CGRect aRect = self.view.frame;
    //    aRect.size.height -= kbSize.height;
    //    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
    //        [self.scrollView scrollRectToVisible: self.activeTextField.frame animated:YES];
    //    }
}

// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.scrollsToTop = YES;
}

#pragma mark - textField delegate method

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![self.confirmPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
        [self.confirmPasswordTextField setDwinkHighLightBorder];
    } else {
        [self.confirmPasswordTextField setDwinkTextFieldStyleWithBorder];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoAvatar"]) {
        PhotoSignUpViewController *photoVC = segue.destinationViewController;
        photoVC.nameStUpperCase = (self.nameTextField.text).uppercaseString;
    }
}

@end
