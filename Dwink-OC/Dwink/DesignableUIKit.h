//
//  DesignableUIKit.h
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface CustomTextField : UITextField

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL leftViewAppear;

@end

IB_DESIGNABLE
@interface CustomButton : UIButton

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL isRound;

@end

IB_DESIGNABLE
@interface CustomView : UIView

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;

@end

IB_DESIGNABLE
@interface CustomImageView : UIImageView

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable BOOL isRound;

@end
