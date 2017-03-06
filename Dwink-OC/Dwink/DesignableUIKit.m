//
//  DesignableUIKit.m
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "DesignableUIKit.h"

@implementation CustomTextField

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setLeftViewAppear:(BOOL)leftViewAppear {
    _leftViewAppear = leftViewAppear;
    self.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(self.frame))];
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end

@implementation CustomButton

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setIsRound:(BOOL)isRound {
    _isRound = isRound;
    if (isRound) {
        self.layer.cornerRadius = self.frame.size.width/2.0;
    } else {
        self.layer.cornerRadius = 0.0;
    }
}

@end

@implementation CustomView

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

@end

@implementation CustomImageView

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setIsRound:(BOOL)isRound {
    _isRound = isRound;
    if (isRound) {
        self.layer.cornerRadius = self.frame.size.width/2.0;
    } else {
        self.layer.cornerRadius = 0.0;
    }
}

@end
