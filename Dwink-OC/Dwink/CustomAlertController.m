//
//  CustomAlertController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/6.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CustomAlertController.h"
#import "UserAuthorizationManager.h"

@interface CustomAlertController ()

@end

@implementation CustomAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)showCancelAlertControllerWithTitle: (NSString *)title message: (NSString *)message action: (actionHandler)actionHandler target: (__kindof UIViewController *)target {
    UIAlertController  *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandler) {
            actionHandler(action);
        }
    }];
    [alertController addAction:cancel];
    [target presentViewController:alertController animated:YES completion:nil];
}

+ (void)showConfirmAlertControllerWithTitle: (NSString *)title message: (NSString *)message confirmText: (NSString *)confirmText action: (actionHandler)actionHandler target: (__kindof UIViewController *)target {
    UIAlertController  *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandler) {
            actionHandler(action);
        }
    }];
    [alertController addAction:confirm];
    [target presentViewController:alertController animated:YES completion:nil];
}

+ (void)showImagePickerControllerWithImagePicker: (UIImagePickerController *)imagePicker target: (__kindof UIViewController *)target completionHandler: (blankHandler)completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose photo" message:@"Chooose photo from listed resources" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *fromCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [target presentViewController:imagePicker animated:YES completion:nil];
        }];
        [alertController addAction:fromCamera];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertAction *fromGallery = [UIAlertAction actionWithTitle:@"Photo Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [target presentViewController:imagePicker animated:YES completion:nil];
        }];
        [alertController addAction:fromGallery];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil];
    [alertController addAction:cancelAction];
    
    [target presentViewController:alertController animated:YES completion:completionHandler];
}

+ (void)forceLogoutAlertControllerForTarget: (__kindof UIViewController *)target {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Information expired" message:@"Your login information is expired, please login again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UserAuthorizationManager logOut];
    }];
    [alertController addAction:confirm];
    
    [target presentViewController:alertController animated:YES completion:nil];
}

@end
