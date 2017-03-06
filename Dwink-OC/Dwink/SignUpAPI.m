//
//  SignUpAPI.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/20.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "SignUpAPI.h"
#import "UserAuthorizationManager.h"
#import "FoundationCategories.h"
#import "ImageAPI.h"

@interface SignUpAPI()

@end

@implementation SignUpAPI

+ (void)creatNewUserInfoWithName: (NSString *)name username: (NSString *)username email: (NSString *)email password: (NSString *)password successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    NSDictionary *infoDic = @{@"email": email, @"username": username, @"fullname": name, @"password": password};
    [sessionManager POST:[NSString stringWithFormat:@"%@/users", mainEndPoint] parameters:infoDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        NSString *token = responseObject[@"token"];
        NSString *idStr = responseObject[@"id"];
        [UserAuthorizationManager saveToken:token userId:idStr];
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
//        NSLog(@"%@", responseDic);
        NSDictionary *errorDic = responseDic[@"errors"];
        NSArray *errorValues = errorDic.allValues;
        NSMutableString *errorInfo = [[NSMutableString alloc]init];
        for (NSArray *detailInfo in errorValues) {
            [errorInfo appendFormat:@"%@\n", detailInfo[0]];
        }
        if (failureHandler) {
            failureHandler([errorInfo copy]);
        }
    }];
}

+ (void)createDwinkAccountForFacebookUser: (NSString *)facebookToken userName: (NSString *)username successHandler: (loginHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/login/facebook", mainEndPoint] parameters:@{@"token": facebookToken, @"username": username} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler(responseObject[@"id"], responseObject[@"token"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
//        NSLog(@"%@", error.debugDescription);
        
        if (failureHandler) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"%@", serializedData);
            
            NSString *errorString;
            NSDictionary *errors = serializedData[@"errors"];
            if (errors.allKeys.count > 0) {
                NSArray *errorArray = errors[errors.allKeys[0]];
                if ([errorArray isKindOfClass:[NSArray class]] && errorArray.count > 0) {
                    errorString = errorArray[0];
                }
            }
            failureHandler(errorString);
        }
        
    }];
}

+ (void)validPhoneNumber: (NSString *)phoneNumber successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/PCheck", mainEndPoint] parameters:@{@"phonenumber": phoneNumber} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureHandler) {
            failureHandler(error.localizedDescription);
        }
    }];
}

@end
