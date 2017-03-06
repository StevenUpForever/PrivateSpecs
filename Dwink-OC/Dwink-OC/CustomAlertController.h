//
//  CustomAlertController.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/6.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^actionHandler)(UIAlertAction *action);

@interface CustomAlertController : UIAlertController

/**
 *  CustomAlertController with Alert type and only cancel action with callback of UIAlertAction
 *
 *  @param title   title of CustomAlertController
 *  @param message message under title
 &  @action        Block with parameter UIAlertAction after button tapped
 *  @param target  UIViewController object to present CustomAlertController
 */

+ (void)showCancelAlertControllerWithTitle: (NSString *)title message: (NSString *)message action: (actionHandler)actionHandler target: (__kindof UIViewController *)target;

/**
 *  CustomAlertController with Alert type and confim & cancel action with callback of UIAlertAction
 *
 *  @param title   title of CustomAlertController
 *  @param message message under title
 *  @confirmText   the title shown on confirm alertAction
 *  @action        Block with parameter UIAlertAction after confirm tapped
 *  @param target  UIViewController object to present CustomAlertController
 */

+ (void)showConfirmAlertControllerWithTitle: (NSString *)title message: (NSString *)message confirmText: (NSString *)confirmText action: (actionHandler)actionHandler target: (__kindof UIViewController *)target;

/**
 *  CustomeAlertController used to select image by UIImagePickerController
 *
 *  @param imagePicker       UIImagePickerController used to pick images
 *  @param target            UIViewController object to present CustomAlertController
 *  @param completionHandler block called when presented this CustomAlertController
 */

+ (void)showImagePickerControllerWithImagePicker: (UIImagePickerController *)imagePicker target: (__kindof UIViewController *)target completionHandler: (blankHandler)completionHandler;

/**
 *  CustomAlertController with Alert type and make user logout due to some reason
 *
 *  @param title   title of CustomAlertController
 *  @param message message under title
 *  @param target  UIViewController object to present CustomAlertController
 */

+ (void)forceLogoutAlertControllerForTarget: (__kindof UIViewController *)target;

@end
