//
//  CustomPostImageView.m
//  Dwink
//
//  Created by Steven Jia on 9/2/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CustomPostImageView.h"
#import "UIKitCategories.h"

@implementation CustomPostImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _imageHasShown = NO;
    }
    return self;
}

@end
