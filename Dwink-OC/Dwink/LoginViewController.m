//
//  ViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeTableViewController.h"
#import "faceBookProfileViewController.h"
#import "LoginAPI.h"
#import "UserAuthorizationManager.h"
#import "UIKitCategories.h"
#import "FoundationCategories.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation LoginViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //textField initial
    
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.userNameTextField setDwinkTextFieldStyle];
    [self.passwordTextField setDwinkTextFieldStyle];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"Waiting for Login";
    [self.view addSubview:self.indicator];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - All Button actions
- (IBAction)loginButton {
    [self.indicator show:YES];
    [LoginAPI userLoginWithLoginInfo:self.userNameTextField.text password:self.passwordTextField.text successHandler:^(NSString *token, NSString *userId, NSString *resposneUsername) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [UserAuthorizationManager loginWithAccessToken:token userId:userId];
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}

- (IBAction)userTermsAction:(UITapGestureRecognizer *)sender {
    UIViewController *termsVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"termsVC"];
    [self.navigationController pushViewController:termsVC animated:YES];
}


- (IBAction)faceBookLogin {
    [self.indicator show:YES];
    FBSDKLoginManager *fbLoginManager = [[FBSDKLoginManager alloc]init];
    [fbLoginManager logOut];
    [FBSDKLoginManager renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
        
    }];
//    @"read_custom_friendlists"
    [fbLoginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [CustomAlertController showCancelAlertControllerWithTitle:error.localizedDescription message:nil action:nil target:self];
            });
        } else {
            if (result.isCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator hide:YES];
                    [CustomAlertController showCancelAlertControllerWithTitle:@"Facebook Error" message:@"Authorization is cancelled" action:nil target:self];
                });
                return;
            }
            //If successfully login with facebook, save fb token and push to fb profile page
            NSString *token = result.token.tokenString;
            [LoginAPI loginWithFacebook:token successHandler:^(BOOL validAccount, NSString *fbIdStr, NSString *fbDwinkToken) {
                if (validAccount) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicator hide:YES];
                        [UserAuthorizationManager loginWithAccessToken:fbDwinkToken userId:fbIdStr];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicator hide:YES];
                        faceBookProfileViewController *fbProfileVC = [[UIStoryboard storyboardWithName:@"LoginSignUp" bundle:nil]instantiateViewControllerWithIdentifier:@"fbProfileVC"];
                        fbProfileVC.fbToken = token;
                        [self.navigationController pushViewController:fbProfileVC animated:YES];
                    });
                }
            } failureHandler:^(NSString *errorString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator hide:YES];
                    [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
                });
            }];
        }
    }];
}

#pragma mark - textField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setDwinkHighLightBorder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resetDwinkStyleBorder];
}

#pragma mark - Selectors

- (void)endEditing {
    [self.view endEditing:YES];
}

@end
