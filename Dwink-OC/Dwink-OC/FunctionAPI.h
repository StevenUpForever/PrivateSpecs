//
//  FunctionAPI.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CommonAPI.h"

@interface FunctionAPI : CommonAPI

/**
 *  Reset password API when know about current password
 *
 *  @param oldPassword    The password currently in using
 *  @param newPassword    New password want to use
 *  @param successHandler callback when successfully reset the password
 *  @param failureHandler callback when failed reset the password
 */

+ (void)resetPassword: (NSString *)oldPassword newPassword: (NSString *)newPassword successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Report problem API call
 *
 *  @param text         text reported to server
 *  @param successHandler callback when successfully sent the problem text to server
 *  @param failureHandler callback when failed sent the problem text to server
 */

+ (void)reportProblemWithText: (NSString *)text successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

@end
