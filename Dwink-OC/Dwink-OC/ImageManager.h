//
//  ImageManager.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject

/**
 *  clean image cache, URL request cahce, reset shared UserInfo
 */

+ (void)clearAllLogoutCacheData;

/**
 *  Clear all possible images' cache of self post
 */

+ (void)clearAllPostImageCache;

/**
 *  Create image url string to upload to, need to called in AWSS3 API
 *
 *  @param imageIndex imageIndex to indicate which image it belongs to
 *
 *  @return NSString type of url string
 */

+ (NSString *)createImageUploadKeyStr: (NSInteger)imageIndex;

@end
