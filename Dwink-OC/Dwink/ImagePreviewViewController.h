//
//  ImagePreviewViewController.h
//  Dwink
//
//  Created by Steven Jia on 9/6/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol imagePreviewDelegate <NSObject>

- (void)didSaveImageButtonClicked: (UIImage *)image imagePicker: (UIImagePickerController *)picker;

@end

@interface ImagePreviewViewController : UIViewController

@property (nonatomic) UIImage *image;
@property (nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) id<imagePreviewDelegate> delegate;

@end
