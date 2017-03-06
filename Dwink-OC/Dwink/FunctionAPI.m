//
//  FunctionAPI.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "FunctionAPI.h"

@implementation FunctionAPI

+ (void)resetPassword: (NSString *)oldPassword newPassword: (NSString *)newPassword successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager PUT:[NSString stringWithFormat:@"%@/user/password", mainEndPoint] parameters:@{@"old_password": oldPassword, @"password": newPassword, @"password_confirmation": newPassword} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureHandler) {
            failureHandler(error.localizedDescription);
        }
    }];
}

+ (void)reportProblemWithText: (NSString *)text successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:@"https://dwink-dev.herokuapp.com/v1/problem" parameters:@{@"problem": text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self reportProblemWithText:text successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
    
}

@end
