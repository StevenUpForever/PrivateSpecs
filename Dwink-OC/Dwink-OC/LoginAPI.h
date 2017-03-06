//
//  NetworkProcess.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/7.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CommonAPI.h"

@interface LoginAPI : CommonAPI

/**
 *  API call to login with username and password
 *
 *  @param userName     username of user need to login
 *  @param password     password of user need to login
 *  @param successHandler callback when successfully logged in with parameter token userId and username
 *  @param failureHandler   callback when failed logged in
 */

+ (void)userLoginWithLoginInfo: (NSString *)userName password: (NSString *)password successHandler: (void(^)(NSString *token, NSString *userId, NSString *resposneUsername))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Login API via Facebook account
 *
 *  @param facebookToken  facebook token from FBSDKProfile to identify user in Dwink
 *  @param successHandler callback to identify the account validation, userId Dwink token when success
 *  @param failureHandler callback when failed to login with facebook except 401 error
 */

+ (void)loginWithFacebook: (NSString *)facebookToken successHandler: (void(^)(BOOL validAccount, NSString *idStr, NSString *token))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  API call to reset password
 *
 *  @param email        email which identify the user
 *  @param successHandler callback when successfully sent the reset password request
 *  @param failureHandler   callback when failed sent the reset password request
 */

+ (void)resetPasswordByEmail: (NSString *)email successHandler: (blankHandler)successHandler error: (errorMessageHandler)failureHandler;

@end
