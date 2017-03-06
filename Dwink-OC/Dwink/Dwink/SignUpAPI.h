//
//  SignUpAPI.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/20.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CommonAPI.h"

typedef void(^loginHandler)(NSString *idStr, NSString *token);

@interface SignUpAPI : CommonAPI

/**
 *  API call to create new user
 *
 *  @param name         name of user
 *  @param username     username of user
 *  @param email        email of user
 *  @param password     password of user
 *  @param successHandler callback when successfully create the new user
 *  @param failureHandler   callback when failed create the new user
 */

+ (void)creatNewUserInfoWithName: (NSString *)name username: (NSString *)username email: (NSString *)email password: (NSString *)password successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  API to create Dwink account via facebook connection
 *
 *  @param facebookToken  facebook token from FBSDKProfile to create account
 *  @param username       username from FBSDKProfile to create account
 *  @param successHandler callback when successfully create account via facebook
 *  @param failureHandler callback when failed create account via facebook
 */

+ (void)createDwinkAccountForFacebookUser: (NSString *)facebookToken userName: (NSString *)username successHandler: (loginHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Valid the input phone number

 @param phoneNumber the input phone number
 @param successHandler callback when valid successfully
 @param failureHandler callback when valid failed
 */
+ (void)validPhoneNumber: (NSString *)phoneNumber successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

@end
