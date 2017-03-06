//
//  CustomIndicator.h
//  Dwink
//
//  Created by Steven Jia on 9/15/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface CustomIndicator : MBProgressHUD

+ (instancetype)newInstanceForView: (UIView *)view;

- (void)showLoadingIndicator;

- (void)hideIndicatorWithSuccessResponse: (BOOL)success text: (NSString *)text;

@end
