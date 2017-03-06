//
//  ImageManager.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "ImageManager.h"
#import "UserInfo.h"
#import "FoundationCategories.h"
#import "ImageAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageManager

+ (void)clearAllLogoutCacheData {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[UserInfo sharedInstance] resetSharedInstance];
}

+ (void)clearAllPostImageCache {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UserInfo *userInfo = [UserInfo sharedInstance];
    NSArray *urlArray = [userInfo.post.imageURLStrArray copy];
    for (NSString *key in urlArray) {
        [imageCache removeImageForKey:key fromDisk:YES];
        [manager.imageCache removeImageForKey:key fromDisk:YES];
        [ImageAPI deleteFileOnS3ServerWithKeyStr:[key getKeyStrFromURLStr] successHandler:^{
            
        } failureHandler:^(NSString *errorString) {
            
        }];
    }
}

+ (NSString *)createImageUploadKeyStr: (NSInteger)imageIndex {
    return [NSString stringWithFormat:@"users/%@/%@post%li.png", [[NSUserDefaults standardUserDefaults] objectForKey:kDwinkUserId], [NSDate currentDateIdentifier], (long)imageIndex];
}

@end
