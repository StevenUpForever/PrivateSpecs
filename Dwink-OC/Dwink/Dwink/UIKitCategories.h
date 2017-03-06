//
//  UIKitCategories.h
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorCategory)

+ (UIColor *)DwinkRed;
+ (UIColor *)DwinkGrey;
+ (UIColor *)selectionGrey;

@end

@interface UITextField (textFieldCategory)

- (void)setDwinkTextFieldStyle;
- (void)setDwinkTextFieldStyleWithBorder;
- (void)setDwinkHighLightBorder;
- (void)resetDwinkStyleBorder;

@end

@interface UIImage (ImageCategory)


/**
 Crop image to size with same width/height ratio

 @param size the size cropped to

 @return the cropped image
 */
- (UIImage *)imageByCroppingImageToSize:(CGSize)size;

/**
 Create image with only background color
 
 @param color the background color of image

 @return the created image
 */
+ (UIImage *)imageFromColor:(UIColor *)color;

/**
 *  Image by first character of user's name otherwise Dwink avatar
 *
 *  @param str NSString type to indicate which image to use
 *
 *  @return instance of UIImage
 */

+ (UIImage *)defaultCharacterImage: (NSString *)str;

/**
 resize image to indicate size with same ratio

 @param newSize the new size resized to

 @return the new resized image
 */
- (UIImage *)resizeImageToSize: (CGSize)newSize;

- (UIImage *)rotateImageToDirection: (UIImageOrientation)direction;


/**
 Resize image within post image frame scope
 */
@property (NS_NONATOMIC_IOSONLY, readonly) UIImage *postResizedImage;

@end

@interface UIImageView (UIImageViewCategory)

/**
 *  Async load image by SDWebImage framework and crop central part
 *
 *  @param url              url to pass into SDWebImage framework
 *  @param placeHolderImage placeHolder image to pass into SDWebImage framework
 */

- (void)asyncLoadImageWithCroppedImageOfURL: (NSURL *)url placeHolderImage: (UIImage *)placeHolderImage;

/**
 Load image after cropped to normal ratio

 @param image the image which need to crop
 */
- (void)loadImageWithCroppedImage: (UIImage *)image;

@end
