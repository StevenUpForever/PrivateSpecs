//
//  CommonAPI.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/5/1.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CommonAPI.h"
#import "UserAuthorizationManager.h"

@implementation CommonAPI

+ (AFHTTPSessionManager *)createNoTokenSessionManager {
    NSURLSessionConfiguration *configue = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configue];
    return sessionManager;
}

+ (AFHTTPSessionManager *)createTokenSessionManager {
    AFHTTPSessionManager *sessionManager = [self createNoTokenSessionManager];
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:kDwinkAccessToken];
    [sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    return sessionManager;
}

+ (void)refreshTokenWithSessionManager: (AFHTTPSessionManager *)sessionManager successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    
    [sessionManager GET:[NSString stringWithFormat:@"%@/login", mainEndPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        //Resave new token to NSUserDefault
        
        NSString *newToken = responseObject[@"token"];
        [UserAuthorizationManager replaceAccessToken:newToken];
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if (response.statusCode >= 500) {
            if (failureHandler) {
                failureHandler(kNeedLogOutKey);
            }
        } else {
            if (failureHandler) {
                failureHandler(error.localizedDescription);
            }
        }
        
    }];
    
}

+ (void)failedHandlerManagerWithSessionManager: (AFHTTPSessionManager *)sessionManager task: (NSURLSessionDataTask *)task error: (NSError *)error completionHandler: (blankHandler)completionHandler failureHandler: (errorMessageHandler)failureHandler {
    
//    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//    NSLog(@"%@", serializedData);
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    
//    NSLog(@"%li", response.statusCode);
    
    if (response.statusCode == 401 || error.code == NSURLErrorTimedOut) {
        [self refreshTokenWithSessionManager:sessionManager successHandler:^{
            if (completionHandler) {
                completionHandler();
            }
        } failureHandler:^(NSString *errorString) {
            if (failureHandler) {
                failureHandler(errorString);
            }
        }];
    } else {
        if (failureHandler) {
            failureHandler(error.localizedDescription);
        }
    }
}

@end
