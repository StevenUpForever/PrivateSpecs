//
//  EditProfileTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/5/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "DesignableUIKit.h"
#import "UserInfo.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "ImageAPI.h"
#import "CustomIndicator.h"
#import "UIKitCategories.h"

@interface EditProfileTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *bioTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic) CustomIndicator *indicator;
@property (nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic, assign) BOOL imageChanged;

@property (nonatomic) UserInfo *sharedInfo;

@end

@implementation EditProfileTableViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedInfo = [UserInfo sharedInstance];
    
    self.nameTextField.text = self.sharedInfo.fullName;
    self.bioTextField.text = self.sharedInfo.bio;
    self.usernameTextField.text = self.sharedInfo.userName;
    self.emailTextField.text = [self.sharedInfo.email isEqual:[NSNull null]] ? @"" : self.sharedInfo.email;
    [self.avatarImageView asyncLoadImageWithCroppedImageOfURL:[NSURL URLWithString:self.sharedInfo.profileImageUrlStr] placeHolderImage:[UIImage defaultCharacterImage:self.sharedInfo.fullName]];
    
    
    self.indicator = [CustomIndicator newInstanceForView:self.tableView];
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    self.imageChanged = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
    [self.avatarImageView layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)submitProcess:(CustomButton *)sender {
    if (self.nameTextField.text.length == 0) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"Name cannot be blank" message:nil action:nil target:self];
    } else if (self.usernameTextField.text.length == 0) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"Username cannot be blank" message:nil action:nil target:self];
    } else if (self.emailTextField.text.length == 0) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"Email cannot be blank" message:nil action:nil target:self];
    } else {
        [self.indicator showLoadingIndicator];
        
        if (self.imageChanged) {
            [ImageAPI updateProfileImage:self.avatarImageView.image successHandler:^{
                
                [[UserInfoNotification notificationCenter]beginNotifyRefreshUI];
                [self updateUserProfile];
                
            } customProgressHandler:^(float progress) {
                self.indicator.mode = MBProgressHUDModeIndeterminate;
                self.indicator.labelText = [NSString stringWithFormat:@"%.2f%% completed", progress];
            } failureHandler:^(NSString *errorString) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator hideIndicatorWithSuccessResponse:NO text:errorString];
                });
            }];
        } else {
            [self updateUserProfile];
        }
        
    }
    
}

- (void)updateUserProfile {
    [SocialAPI updateUserProfile:self.nameTextField.text bio:self.bioTextField.text username:self.usernameTextField.text email:self.emailTextField.text private:self.sharedInfo.privateProfile unreadNotifications:self.sharedInfo.unreadNotifyCount successHandler:^{
        
        [[UserInfoNotification notificationCenter]beginNotifyRefreshUI];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
            [self.view endEditing:YES];
        });
        
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:@"Update profile error" message:errorString action:nil target:self];
        });
    }];
}

- (IBAction)tapAvatar:(UITapGestureRecognizer *)sender {
    [CustomAlertController showImagePickerControllerWithImagePicker:self.imagePicker target:self completionHandler:nil];
}

#pragma mark - UIImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *changeImage = info[UIImagePickerControllerOriginalImage];
    [self.avatarImageView loadImageWithCroppedImage:changeImage];
    self.imageChanged = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
