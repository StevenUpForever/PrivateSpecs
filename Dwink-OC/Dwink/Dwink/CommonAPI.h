//
//  CommonAPI.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/5/1.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@class UserInfo;
typedef void(^errorMessageHandler)(NSString *errorString);
typedef void(^customProgressHandler)(float progress);
typedef void(^userInfoHandler)(UserInfo *userInfo);

static NSString *S3MainEndPoint = @"https://dwink.s3.amazonaws.com";

//#warning Need to config

#ifdef DEBUG

static NSString *mainEndPoint = @"https://dwink-staging.herokuapp.com/v1";
//static NSString *S3MainEndPoint = @"https://dwink.s3.amazonaws.com";

#else

static NSString *mainEndPoint = @"https://dwink.herokuapp.com/v1";
//static NSString *S3MainEndPoint = @"https://bucketeer-3a7c19c1-f658-40da-b901-7c3b2a0dd56c.s3.amazonaws.com/public";

#endif

static NSString *kNeedLogOutKey = @"Need logout";

@class AWSS3TransferManagerUploadRequest;
@interface CommonAPI : NSObject

/**
 *  Create SessionManager with no token
 *
 *  @return instance of AFHTTPSessionManager
 */

+ (AFHTTPSessionManager *)createNoTokenSessionManager;

/**
 *  Create SessionManager with current accessToken
 *
 *  @return instance of AFHTTPSessionManager
 */

+ (AFHTTPSessionManager *)createTokenSessionManager;

/**
 *  Refresh API with success and failed callback
 *
 *  @param sessionManager sessionManager contained current expired accessToken
 *  @param successHandler callback when successfully saved new accessToken
 *  @param failureHandler   callback when failed to get new accessToken
 */

+ (void)refreshTokenWithSessionManager: (AFHTTPSessionManager *)sessionManager successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Common failedHandler processor may used in some API with refresh API intergrated and error message callback
 *
 *  @param sessionManager    sessionManager which contains accessToken which need be refreshed
 *  @param task              task to get HTTP response code
 *  @param error             error to locate localization error message
 *  @param completionHandler callback when finish refresh accessToken
 *  @param failureHandler      failureHandler customized by each API call
 */

+ (void)failedHandlerManagerWithSessionManager: (AFHTTPSessionManager *)sessionManager task: (NSURLSessionDataTask *)task error: (NSError *)error completionHandler: (blankHandler)completionHandler failureHandler: (errorMessageHandler)failureHandler;

@end
