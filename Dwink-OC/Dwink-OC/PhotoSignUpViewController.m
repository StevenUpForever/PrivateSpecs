//
//  PhotoSignUpViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/6.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "PhotoSignUpViewController.h"
#import "ImageAPI.h"
#import "UIKitCategories.h"
#import "UserAuthorizationManager.h"

@interface PhotoSignUpViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarChooseImageView;

@property (nonatomic) MBProgressHUD *indicator;

@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation PhotoSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.indicator.labelText = @"0% completed";
    [self.view addSubview:self.indicator];
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    if (self.nameStUpperCase) {
        UIImage *defaultImage = [UIImage defaultCharacterImage:self.nameStUpperCase];
        self.avatarChooseImageView.image = defaultImage;
    }
}

- (void)viewDidLayoutSubviews {
    self.avatarChooseImageView.layer.cornerRadius = self.avatarChooseImageView.frame.size.width/2.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pictureChoose {
    [CustomAlertController showImagePickerControllerWithImagePicker:self.imagePicker target:self completionHandler:nil];
}

- (IBAction)signUpWithPhoto {
    self.indicator.labelText = @"0% completed";
    [self.indicator show:YES];
    [ImageAPI updateProfileImage:self.avatarChooseImageView.image successHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [UserAuthorizationManager loginTransition];
        });
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
}

- (IBAction)Skip {
    [self.indicator hide:YES];
    [UserAuthorizationManager loginTransition];
    
    [ImageAPI updateProfileImage:self.avatarChooseImageView.image successHandler:^{
    } customProgressHandler:^(float progress) {
    } failureHandler:^(NSString *errorString) {
    }];
}

#pragma mark - ImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *changeImage = info[UIImagePickerControllerOriginalImage];
    [self.avatarChooseImageView loadImageWithCroppedImage:changeImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
