//
//  UIKitCategories.m
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UIKitCategories.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIColor (ColorCategory)

+ (UIColor *)DwinkRed {
    return [UIColor colorWithRed:222.0/255 green:0.0/255 blue:49.0/255 alpha:1.0];
}

+ (UIColor *)DwinkGrey {
    return [UIColor colorWithRed:147.0/255 green:159.0/255 blue:152.0/255 alpha:1.0];
}

+ (UIColor *)selectionGrey {
    return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
}

@end

@implementation UITextField (textFieldCategory)

- (void)setDwinkTextFieldStyle {
    self.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, self.frame.size.height)];
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setDwinkTextFieldStyleWithBorder {
    [self setDwinkTextFieldStyle];
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [UIColor DwinkGrey].CGColor;
}

- (void)setDwinkHighLightBorder {
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [UIColor DwinkRed].CGColor;
}

- (void)resetDwinkStyleBorder {
    self.layer.borderWidth = 0.0;
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

@end

@implementation UIImage (ImageCategory)

- (UIImage *)imageByCroppingImageToSize:(CGSize)size
{
    double refWidth = CGImageGetWidth(self.CGImage);
    double refHeight = CGImageGetHeight(self.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    
    //Prevent if image from camera will turn to right
//    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.imageOrientation];
    CFRelease(imageRef);
    return cropped;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)defaultCharacterImage: (NSString *)str {
    if (str == nil || str.length == 0) {
        return [UIImage imageNamed:@"penguin"];
    }
    NSString *upperCaseStr = str.uppercaseString;
    for (int index = 0; index < upperCaseStr.length; index++) {
        char character = [upperCaseStr characterAtIndex:index];
        if (character - 'A' >= 0 && character - 'A' <= 26) {
            return [UIImage imageNamed:[NSString stringWithFormat:@"%c_default", character]];
        }
    }
    return [UIImage imageNamed:@"penguin"];
}

- (UIImage *)resizeImageToSize: (CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)rotateImageToDirection: (UIImageOrientation)direction {
    return [[UIImage alloc]initWithCGImage:self.CGImage scale:1.0 orientation:direction];
}

- (UIImage *)postResizedImage {
    if (self.size.height < 1000 && self.size.width < 1000) {
        return self;
    }
    
    CGFloat scale = 1.0;
    if (self.size.height > self.size.width) {
        scale = 1000/self.size.height;
    } else {
        scale = 1000/self.size.width;
    }
    CGSize newSize = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(scale, scale));
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImageView (UIImageViewCategory)

- (void)asyncLoadImageWithCroppedImageOfURL: (NSURL *)url placeHolderImage: (UIImage *)placeHolderImage {
    [self sd_setImageWithURL:url placeholderImage:placeHolderImage options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            CGFloat minEdge = MIN(self.image.size.width, self.image.size.height);
            self.image = [image imageByCroppingImageToSize:CGSizeMake(minEdge, minEdge)];
        }
    }];
}

- (void)loadImageWithCroppedImage: (UIImage *)image {
    CGFloat minEdge = MIN(image.size.width, image.size.height);
    self.image = [image imageByCroppingImageToSize:CGSizeMake(minEdge, minEdge)];
}

@end
