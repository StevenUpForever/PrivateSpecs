//
//  ImageAPI.m
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "ImageAPI.h"
#import "ImageManager.h"
#import "UIKitCategories.h"
#import "FoundationCategories.h"
#import "UserInfo.h"
#import <AWSS3/AWSS3.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageAPI

+ (AWSS3TransferManagerUploadRequest *)createUploadRequestWithName: (NSString *)name keyStr: (NSString *)keyStr image: (UIImage *)image {
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    //    #warning Need to config
    
    uploadRequest.bucket = @"dwink";
    //#ifdef DEBUG
    //    uploadRequest.bucket = @"dwink";
    //#else
    //    uploadRequest.bucket = @"bucketeer-3a7c19c1-f658-40da-b901-7c3b2a0dd56c";
    //#endif
    uploadRequest.key = keyStr;
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
    
    [UIImageJPEGRepresentation(image.postResizedImage, 0.8) writeToFile:filePath atomically:YES];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    uploadRequest.body = fileURL;
    uploadRequest.contentType = @"image/jpeg";
    return uploadRequest;
}

+ (void)updateProfileImage: (UIImage *)image successHandler: (blankHandler)successHandler customProgressHandler: (customProgressHandler)customProgressHandler failureHandler: (errorMessageHandler)failureHandler  {
    NSString *keyStr = [NSString stringWithFormat:@"users/%@/%@avatar.png", [[NSUserDefaults standardUserDefaults] objectForKey:kDwinkUserId], [NSDate currentDateIdentifier]];
    AWSS3TransferManagerUploadRequest *uploadRequest = [ImageAPI createUploadRequestWithName:@"avatar" keyStr:keyStr image:image];
    uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            customProgressHandler((float)totalBytesSent/totalBytesExpectedToSend * 100);
        });
    };
    AWSS3TransferManager *uploadManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[uploadManager upload:uploadRequest]continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if (task.error) {
            
            if (failureHandler) {
                failureHandler(task.error.localizedDescription);
            }
            
        } else {
            [uploadManager clearCache];
            NSString *avatarPath = [NSString stringWithFormat:@"%@/%@", S3MainEndPoint, keyStr];
            [self updateUserImageURLStr:avatarPath successHandler:successHandler failureHandler:failureHandler];
        }
        return nil;
    }];
}

+ (void)uploadAllPostImages: (NSArray<UIImage *> *)imageArray successHandler: (void(^)(NSArray *imageStrArray))successHandler failureHandler: (errorMessageHandler)failureHandler {
    
    NSMutableArray *imageURLArray = [[NSMutableArray alloc]init];
    NSMutableArray<AWSTask *> *taskArray = [[NSMutableArray alloc]init];
    
    AWSS3TransferManager *uploadManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //Create upload request for each UIImage
    
    for (int index = 0; index < imageArray.count; index++) {
        NSString *keyStr = [ImageManager createImageUploadKeyStr:index];
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [ImageAPI createUploadRequestWithName:[NSString stringWithFormat:@"post%i", index] keyStr:keyStr image:imageArray[index]];
        
        uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
            dispatch_async(dispatch_get_main_queue(), ^{
                //                NSLog(@"%@", [NSString stringWithFormat:@"Image%i: %f", index, (float)totalBytesSent/totalBytesExpectedToSend * 100]);
            });
        };
        AWSTask *task = [uploadManager upload:uploadRequest];
        [taskArray addObject:task];
        [task continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"%@", task.error.localizedDescription);
            } else {
                [imageURLArray addObject:[NSString stringWithFormat:@"%@/%@", S3MainEndPoint, keyStr]];
            }
            return nil;
        }];
    }
    
    //Upload task notify that all tasks are done or not
    
    AWSTask *allTask = [AWSTask taskForCompletionOfAllTasks:taskArray];
    [allTask continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if (task.error) {
            if (failureHandler) {
                failureHandler(@"Upload images failed");
            }
        } else {
            [uploadManager clearCache];
            if (successHandler) {
                successHandler(imageURLArray);
            }
        }
        return nil;
    }];
    
}

+ (void)deleteFileOnS3ServerWithKeyStr: (NSString *)keyStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AWSS3DeleteObjectRequest *deleteRequest = [AWSS3DeleteObjectRequest new];
    deleteRequest.bucket = @"dwink";
    //#ifdef DEBUG
    //    uploadRequest.bucket = @"dwink";
    //#else
    //    uploadRequest.bucket = @"bucketeer-3a7c19c1-f658-40da-b901-7c3b2a0dd56c";
    //#endif
    deleteRequest.key = keyStr;
    AWSS3 *s3 = [AWSS3 defaultS3];
    [[s3 deleteObject:deleteRequest] continueWithBlock:^id _Nullable(AWSTask<AWSS3DeleteObjectOutput *> * _Nonnull task) {
        if (task.error) {
            if (failureHandler) {
                failureHandler(task.debugDescription);
            }
        } else {
            if (successHandler) {
                successHandler();
            }
        }
        return nil;
    }];
}

#pragma mark - private methods

+ (void)updateUserImageURLStr: (NSString *)urlStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    AFHTTPSessionManager *sessionManager = [self createTokenSessionManager];
    NSDictionary *paramater = @{@"profile_img": urlStr};
    [sessionManager PUT:[NSString stringWithFormat:@"%@/user/profile-image", mainEndPoint] parameters:paramater success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //        NSLog(@"%@", responseObject);
        
        UserInfo *userInfo = [UserInfo sharedInstance];
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        NSString *profileImageURLStr = [userInfo.profileImageUrlStr copy];
        [imageCache removeImageForKey:profileImageURLStr];
        [ImageAPI deleteFileOnS3ServerWithKeyStr:[profileImageURLStr getKeyStrFromURLStr] successHandler:^{
            
        } failureHandler:^(NSString *errorString) {
            
        }];
        
        [userInfo loadResponseObj:responseObject];
        
        if (successHandler) {
            successHandler();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
            [self updateUserImageURLStr:urlStr successHandler:successHandler failureHandler:failureHandler];
        } failureHandler:failureHandler];
    }];
}

@end
