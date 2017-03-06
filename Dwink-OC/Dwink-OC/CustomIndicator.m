//
//  CustomIndicator.m
//  Dwink
//
//  Created by Steven Jia on 9/15/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CustomIndicator.h"

@interface CustomIndicator()

@end

@implementation CustomIndicator

+ (instancetype)newInstanceForView: (UIView *)view {
    CustomIndicator *newIndicator = [[self alloc]initWithView:view];
    [view addSubview:newIndicator];
    return newIndicator;
}

- (void)showLoadingIndicator {
    self.mode = MBProgressHUDModeIndeterminate;
    self.labelText = @"Loading...";
    [self show:YES];
}

- (void)hideIndicatorWithSuccessResponse: (BOOL)success text: (NSString *)text {
    UIImage *customImage = success ? [[UIImage imageNamed:@"successIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [[UIImage imageNamed:@"errorIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:customImage];
    imageView.tintColor = [UIColor whiteColor];
    self.customView = imageView;
    self.mode = MBProgressHUDModeCustomView;
    self.labelText = text;
    [self hide:YES afterDelay:1.0];
}

@end
