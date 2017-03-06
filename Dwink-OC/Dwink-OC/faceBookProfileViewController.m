//
//  faceBookProfileViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "faceBookProfileViewController.h"
#import "DesignableUIKit.h"
#import "UIKitCategories.h"
#import "UserAuthorizationManager.h"
#import "ImageAPI.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "SignUpAPI.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface faceBookProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet CustomTextField *userNameTextField;

@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation faceBookProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Facebook Profile";
    
    self.userNameTextField.delegate = self;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewEndEditing)]];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"0% completed";
    [self.view addSubview:self.indicator];
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    
    //Get current Facebook login user information
    FBSDKProfile *userProfile = [FBSDKProfile currentProfile];
    self.userNameTextField.text = userProfile.name ? [userProfile.name stringByReplacingOccurrencesOfString:@" " withString:@""] : @"";
    self.avatarImageView.image = [UIImage defaultCharacterImage:userProfile.name];
    NSData *imageData = [NSData dataWithContentsOfURL:[userProfile imageURLForPictureMode:FBSDKProfilePictureModeNormal size:self.avatarImageView.bounds.size]];
    if (imageData) {
        self.avatarImageView.image = [UIImage imageWithData:imageData];
    }
}

//Step to avoid cornerRadius valid before autoLayouts
- (void)viewDidLayoutSubviews {
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doneButton {
    self.indicator.labelText = @"0% completed";
    [self.indicator show:YES];
    NSString *usernameText = self.userNameTextField.text;
    if (usernameText == nil || usernameText.length == 0 || [usernameText stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:@"Please correct your username" message:nil action:nil target:self];
        });
    } else {
        [SignUpAPI createDwinkAccountForFacebookUser:self.fbToken userName:self.userNameTextField.text successHandler:^(NSString *idStr, NSString *token) {
            
            [UserAuthorizationManager saveToken:token userId:idStr];
            
            [ImageAPI updateProfileImage:self.avatarImageView.image successHandler:^{
                
                [self updateUserEmailAndUserName];
                
            } customProgressHandler:^(float progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.indicator.labelText = [NSString stringWithFormat:@"%.2f%% completed", progress];
                });
            } failureHandler:^(NSString *errorString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator hide:YES];
                    [CustomAlertController showCancelAlertControllerWithTitle:@"Upload error, please try again" message:nil action:nil target:self];
                });
            }];
            
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
            });
        }];
    }
}

- (void)updateUserEmailAndUserName {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name,email"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                  id result, NSError *error) {
         
         if (error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.indicator hide:YES];
                 [CustomAlertController showCancelAlertControllerWithTitle:@"Get user email failed" message:nil action:nil target:self];
             });
         }
         if (result) {
             [SocialAPI updateUserProfile:result[@"name"] bio:nil username:nil email:result[@"email"] private:NO unreadNotifications:0 successHandler:^{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.indicator hide:YES];
                     [self.userNameTextField resignFirstResponder];
                     [UserAuthorizationManager loginTransition];
                 });
             } failureHandler:^(NSString *errorString) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.indicator hide:YES];
                     [CustomAlertController showCancelAlertControllerWithTitle:@"Upload user profile failed" message:nil action:nil target:self];
                 });
             }];
         }
     }];
}

- (IBAction)pictureChooseAction {
    [CustomAlertController showImagePickerControllerWithImagePicker:self.imagePicker target:self completionHandler:nil];
}

#pragma mark - Custom selector

- (void)mainViewEndEditing {
    [self.view endEditing:YES];
}

#pragma mark - Textfiled delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *changeImage = info[UIImagePickerControllerOriginalImage];
    [self.avatarImageView loadImageWithCroppedImage: changeImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
