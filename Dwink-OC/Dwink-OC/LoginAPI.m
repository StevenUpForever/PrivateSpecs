//
//  NetworkProcess.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/7.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "LoginAPI.h"
#import "FoundationCategories.h"

@interface LoginAPI()

@end

@implementation LoginAPI

+ (void)userLoginWithLoginInfo: (NSString *)userName password: (NSString *)password successHandler: (void(^)(NSString *token, NSString *userId, NSString *resposneUsername))successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    NSDictionary *infoDic = @{@"username": userName, @"password": password};
    [sessionManager POST:[NSString stringWithFormat:@"%@/login", mainEndPoint] parameters:infoDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        NSString *tokenStr = responseObject[@"token"];
        NSString *idStr = responseObject[@"id"];
        NSString *resposneUsername = responseObject[@"username"];
        if (successHandler) {
            successHandler(tokenStr, idStr, resposneUsername);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            failureHandler(@"Invalid Credentials");
        }
    }];
}

+ (void)loginWithFacebook: (NSString *)facebookToken successHandler: (void(^)(BOOL validAccount, NSString *fbIdStr, NSString *fbDwinkToken))successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager GET:[NSString stringWithFormat:@"%@/login/facebook?token=%@", mainEndPoint, facebookToken] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler(YES, responseObject[@"id"], responseObject[@"token"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //        NSLog(@"%@", error.description);
        //
//                NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//                NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//        
//                NSLog(@"%@", serializedData);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        //        NSLog(@"%li", (long)response.statusCode);
        
        if (response.statusCode == 401 || response.statusCode == 411) {
            if (successHandler) {
                successHandler(NO, nil, nil);
            }
        } else {
            if (failureHandler) {
                failureHandler(@"Facebook authorize failed");
            }
        }
        
    }];
}

+ (void)resetPasswordByEmail: (NSString *)email successHandler: (blankHandler)successHandler error: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    NSString *urlStr = [NSString stringWithFormat:@"%@/password/reset?email=%@", mainEndPoint, email];
    [sessionManager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        NSDictionary *errorDic = responseDic[@"errors"];
        NSArray *emailError = errorDic[@"email"];
        NSString *emailErrorStr = emailError[0];
        if (failureHandler) {
            failureHandler(emailErrorStr);
        }
    }];
}

@end
