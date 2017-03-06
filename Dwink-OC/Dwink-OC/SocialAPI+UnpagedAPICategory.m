//
//  SocialAPI+SocialAPIUserInfoCategory.m
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "SocialAPI+UnpagedAPICategory.h"
#import "CommentModel.h"
#import "UserInfo.h"

@implementation SocialAPI (UnpagedAPICategory)

+ (void)likePost: (NSString *)userId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/users/%@/post/likes", mainEndPoint, userId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self likePost:userId successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)unLikePost: (NSString *)userId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/users/%@/post/likes", mainEndPoint, userId] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self likePost:userId successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)createNewPostWithText: (NSString *)text imageStrArray: (NSArray *)imageStrArray video: (NSString *)video successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    NSDictionary *parameters;
    imageStrArray = [imageStrArray sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 characterAtIndex:obj1.length - 5] > [obj2 characterAtIndex:obj2.length - 5];
    }];
    if (text) {
        parameters = @{@"text": text, @"images": imageStrArray, @"video": video ? video : @""};
    } else {
        parameters = @{@"images": imageStrArray, @"video": video ? video : @""};
    }
    [sessionManager POST:[NSString stringWithFormat:@"%@/user/post", mainEndPoint] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self createNewPostWithText:text imageStrArray:imageStrArray video:video successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)followUser: (NSString *)idStr successHandler:(userInfoHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/user/following/%@", mainEndPoint, idStr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        UserInfo *info = [[UserInfo alloc]init];
        [info loadResponseObj:responseObject];
        
        if (successHandler) {
            successHandler(info);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self followUser:idStr successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)unFollowUser: (NSString *)idStr successHandler:(blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/user/following/%@", mainEndPoint, idStr] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self unFollowUser:idStr successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)getCurrentUserWithSuccessBlock: (void(^)(UserInfo *sharedUserInfo))successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager GET:[NSString stringWithFormat:@"%@/user", mainEndPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//                NSLog(@"%@", responseObject);
        
        UserInfo *sharedUserInfo = [UserInfo sharedInstance];
        [sharedUserInfo loadResponseObj:responseObject];
        
        if (successHandler) {
            successHandler(sharedUserInfo);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self getCurrentUserWithSuccessBlock:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)getIndicateUserWithIdStr: (NSString *)idStr successHandler: (void(^)(UserInfo *userInfo))successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager GET:[NSString stringWithFormat:@"%@/users/%@", mainEndPoint, idStr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        UserInfo *newUser = [[UserInfo alloc]init];
        [newUser loadResponseObj:responseObject];
        
        if (successHandler) {
            successHandler(newUser);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self getIndicateUserWithIdStr:idStr successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)updateUserProfile: (NSString *)name bio: (NSString *)bio username: (NSString *)username email: (NSString *)email private: (BOOL)private unreadNotifications: (NSInteger)unreadNotifications successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    if (name && name.length > 0) {
        parameter[@"fullname"] = name;
    }
    if (bio && bio.length > 0) {
        parameter[@"bio"] = bio;
    }
    if (username && username.length > 0) {
        parameter[@"username"] = username;
    }
    if (email && email.length > 0) {
        parameter[@"email"] = email;
    }
    parameter[@"unread_notification_count"] = [NSNumber numberWithInteger:unreadNotifications];
    parameter[@"private"] = [NSNumber numberWithBool:private];
    [sessionManager PUT:[NSString stringWithFormat:@"%@/user", mainEndPoint] parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"%@", responseObject);
        
        [[UserInfo sharedInstance] loadResponseObj:responseObject];
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 422) {
            
            NSString *errorString = @"Error to continue, please check all your fields";
            
            NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
            NSDictionary *errors = errorDict[@"errors"];
            if ([errors isKindOfClass:[NSDictionary class]]) {
                if (errors.allKeys.count > 0) {
                    NSArray *errorArray = errors[errors.allKeys[0]];
                    if ([errorArray isKindOfClass:[NSArray class]] && errorArray.count > 0) {
                        errorString = errorArray[0];
                    }
                }
            }
            if (failureHandler) {
                failureHandler(errorString);
            }
        } else {
            [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
                [self updateUserProfile:name bio:bio username:username email:email private:private unreadNotifications:unreadNotifications successHandler:successHandler failureHandler:failureHandler];
            } failureHandler:failureHandler];
        }
    }];
}

+ (void)postNewComments: (NSString *)idStr commentStr: (NSString *)commentStr successHandler: (void(^)(CommentModel *comment))successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/users/%@/post/comments", mainEndPoint, idStr] parameters:@{@"comment": commentStr} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        CommentModel *newComment = [[CommentModel alloc]init];
        [newComment loadData:responseObject];
        
        if (successHandler) {
            successHandler(newComment);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self postNewComments:idStr commentStr:commentStr successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)deleteComment: (NSString *)userId commentId: (NSString *)commentId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/users/%@/post/comments/%@", mainEndPoint, userId, commentId] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self deleteComment:userId commentId:commentId successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

+ (void)reportUserWithReason: (NSString *)reason idStr: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/users/%@/report", mainEndPoint, idStr] parameters:@{@"reason": reason} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 400 && failureHandler) {
            failureHandler(@"Already report this user");
        } else {
            [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
                [self reportUserWithReason:reason idStr:idStr successHandler:successHandler failureHandler:failureHandler];
            } failureHandler:failureHandler];
        }
    }];
}

+ (void)blockUserWithId: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/users/%@/block", mainEndPoint, idStr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 400 && failureHandler) {
            failureHandler(@"Already block this user");
        } else {
            [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
                [self blockUserWithId:idStr successHandler:successHandler failureHandler:failureHandler];
            } failureHandler:failureHandler];
        }
    }];
}

+ (void)unBlockUserWithId: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/users/%@/block", mainEndPoint, idStr] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response.statusCode == 400 && failureHandler) {
            failureHandler(@"Already unblock this user");
        } else {
            [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
                [self unBlockUserWithId:idStr successHandler:successHandler failureHandler:failureHandler];
            } failureHandler:failureHandler];
        }
    }];
}

+ (void)acceptPendingRequest: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager POST:[NSString stringWithFormat:@"%@/user/followers/requests/%@", mainEndPoint, idStr] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureHandler) {
            failureHandler(@"Error to accept this request");
        }
    }];
}

+ (void)ignorePendingRequest: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/user/followers/requests/%@", mainEndPoint, idStr] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureHandler) {
            failureHandler(@"Error to ignore this request");
        }
    }];
}

+ (void)cancelPendingRequestTo: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    [sessionManager DELETE:[NSString stringWithFormat:@"%@/user/following/requests/%@", mainEndPoint, idStr] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successHandler) {
            successHandler();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureHandler) {
            failureHandler(@"Error to ignore this request");
        }
    }];
}

@end
