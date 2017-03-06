//
//  ImageAPI.h
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CommonAPI.h"

@interface ImageAPI : CommonAPI

/**
 *  Create AWSS3 upload request to upload images
 *
 *  @param name   request name
 *  @param keyStr request key
 *  @param image  image need to upload
 *
 *  @return instance of AWSS3TransferManagerUploadRequest
 */

+ (AWSS3TransferManagerUploadRequest *)createUploadRequestWithName: (NSString *)name keyStr: (NSString *)keyStr image: (UIImage *)image;

/**
 *  API call to update profile image
 *
 *  @param image         image need to upload to server
 *  @param successHandler  callback when successfully uploaded the profile image
 *  @param customProgressHandler callback of progress number
 *  @param failureHandler    callback when failed uploaded the profile image
 */

+ (void)updateProfileImage: (UIImage *)image successHandler: (blankHandler)successHandler customProgressHandler: (customProgressHandler)customProgressHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Upload images API via AWSS3 framework
 *
 *  @param imageArray     image array contains UIImages need upload
 *  @param successHandler callback when successfully upload all images, paramaters are array of image url
 *  @param failureHandler callback when failed upload all images
 */

+ (void)uploadAllPostImages: (NSArray<UIImage *> *)imageArray successHandler: (void(^)(NSArray *imageStrArray))successHandler failureHandler: (errorMessageHandler)failureHandler;


/**
 Delete image on S3 server

 @param keyStr         key string to identify image
 @param successHandler block when successfully deleted the image
 @param failureHandler block when failed deleted the image
 */
+ (void)deleteFileOnS3ServerWithKeyStr: (NSString *)keyStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

@end
