//
//  UserInfoNotification.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/16/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserInfoNotification.h"
#import "HomeTableViewController.h"
#import "UserInfoTableViewController.h"
#import "MoreTableViewController.h"
#import "FoundationCategories.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "UserInfo.h"
#import <Parse/Parse.h>

NSString *const kBeginRefreshUI = @"BeginRefreshUI";
NSString *const kFailedRefreshUI = @"failedRefreshUI";

@interface UserInfoNotification()

@property (nonatomic, assign) BOOL homeNeedRefresh;
@property (nonatomic, assign) BOOL userInfoHomeFeedNeedRefresh;
@property (nonatomic, assign) BOOL userInfoMoreNeedRefresh;
@property (nonatomic, assign) BOOL moreTableNeedRefresh;

@end

@implementation UserInfoNotification

+ (instancetype)notificationCenter {
    static dispatch_once_t onceToken;
    static UserInfoNotification *notificationCenter;
    dispatch_once(&onceToken, ^{
        notificationCenter = [[UserInfoNotification alloc]init];
    });
    return notificationCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _homeNeedRefresh = NO;
        _userInfoHomeFeedNeedRefresh = NO;
        _userInfoMoreNeedRefresh = NO;
        _moreTableNeedRefresh = NO;
        _needBeginUploadingHint = NO;
    }
    return self;
}

#pragma mark - Local notification

- (void)beginNotifyRefreshUI {
    self.homeNeedRefresh = YES;
    self.userInfoHomeFeedNeedRefresh = YES;
    self.userInfoMoreNeedRefresh = YES;
    self.moreTableNeedRefresh = YES;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kBeginRefreshUI object:self];
}

- (void)failedRefreshUI {
    self.homeNeedRefresh = NO;
    self.userInfoHomeFeedNeedRefresh = NO;
    self.userInfoMoreNeedRefresh = NO;
    self.moreTableNeedRefresh = NO;
    self.needBeginUploadingHint = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:kFailedRefreshUI object:self];
}

- (void)finishRefreshUI: (__kindof UIViewController *)target {
    if ([target isMemberOfClass:[HomeTableViewController class]] && self.homeNeedRefresh) {
        self.homeNeedRefresh = NO;
        self.userInfoHomeFeedNeedRefresh = NO;
    } else if ([target isMemberOfClass:[UserInfoTableViewController class]]) {
        UserInfoTableViewController *userInfoVC = target;
        if (userInfoVC.viewModel.type == userInfoVCTypeHomeFeed && self.userInfoHomeFeedNeedRefresh) {
            self.userInfoHomeFeedNeedRefresh = NO;
        } else {
            self.userInfoMoreNeedRefresh = NO;
        }
    } else if ([target isMemberOfClass:[MoreTableViewController class]] && self.moreTableNeedRefresh) {
        self.moreTableNeedRefresh = NO;
        self.userInfoMoreNeedRefresh = NO;
    }
}

- (BOOL)needRefreshUI:(__kindof UIViewController *)target {
    if ([target isMemberOfClass:[HomeTableViewController class]]) {
        return self.homeNeedRefresh;
    } else if ([target isMemberOfClass:[UserInfoTableViewController class]]) {
        UserInfoTableViewController *userInfoVC = target;
        if (userInfoVC.viewModel.type == userInfoVCTypeHomeFeed && self.userInfoHomeFeedNeedRefresh) {
            return self.userInfoHomeFeedNeedRefresh;
        } else {
            return self.userInfoMoreNeedRefresh;
        }
    } else if ([target isMemberOfClass:[MoreTableViewController class]] && self.moreTableNeedRefresh) {
        return self.moreTableNeedRefresh;
    } else {
        return NO;
    }
}

- (void)getUnreadNotificationCountAndSet: (UITabBarItem *)item {
    [SocialAPI getCurrentUserWithSuccessBlock:^(UserInfo *sharedUserInfo) {
        NSUInteger count = sharedUserInfo.unreadNotifyCount;
        if (count == 0) {
            self.notificationBubbleValue = nil;
        } else if (count <= 99) {
            self.notificationBubbleValue = [NSString stringWithFormat:@"%lu", (unsigned long)count];
        } else {
            self.notificationBubbleValue = @"99+";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            item.badgeValue = self.notificationBubbleValue;
        });
    } failureHandler:^(NSString *errorString) {
        
    }];
}

- (void)clearUnreadNotificationCountAndSet: (UITabBarItem *)item {
    [SocialAPI updateUserProfile:nil bio:nil username:nil email:nil private:[UserInfo sharedInstance].privateProfile unreadNotifications:0 successHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notificationBubbleValue = nil;
            item.badgeValue = self.notificationBubbleValue;
        });
    } failureHandler:^(NSString *errorString) {
        
    }];
}

//#pragma mark - Push notification
//
//+ (void)pushNotificationToUser: (NSString *)idStr notifyType: (notificationType)type {
//    PFPush *push = [[PFPush alloc] init];
//    [push setChannel:idStr.setChannelIdStr];
//    NSString *pushStr;
//    NSString *selfUserName = [UserInfo sharedInstance].userName;
//    switch (type) {
//        case notificationTypeUserFollowed: {
//            pushStr = [NSString stringWithFormat:@"%@ is now following you", selfUserName];
//            break;
//        }
//        case notificationTypePostComment: {
//            pushStr = [NSString stringWithFormat:@"%@ has commented on your post", selfUserName];
//            break;
//        }
//        case notificationTypeCommentMentioned: {
//            pushStr = [NSString stringWithFormat:@"%@ has mentioned you in a comment", selfUserName];
//            break;
//        }
//        case notificationTypePostMentioned: {
//            pushStr = [NSString stringWithFormat:@"%@ has mentioned you in a post", selfUserName];
//            break;
//        }
//        case notificationTypePostLiked: {
//            pushStr = [NSString stringWithFormat:@"%@ likes your post", selfUserName];
//            break;
//        }
//    }
//    [push setMessage:pushStr];
////    [push setData:@{@"alert": [pushStr copy],
////                    @"badge": @1}];
//    [push sendPushInBackground];
//}

@end
