//
//  UserInfoNotification.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/16/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, notificationType) {
    notificationTypeUserFollowed,
    notificationTypePostComment,
    notificationTypeCommentMentioned,
    notificationTypePostMentioned,
    notificationTypePostLiked
};

extern NSString *const kBeginRefreshUI;
extern NSString *const kFailedRefreshUI;

@class UserInfo;
@interface UserInfoNotification : NSObject

+ (instancetype)notificationCenter;

@property (nonatomic, assign) BOOL needBeginUploadingHint;

/**
 *  Begin notify refresh UI action include set all booleans to YES and post notification
 */

- (void)beginNotifyRefreshUI;

- (void)failedRefreshUI;

/**
 *  Add Observer for different kind of controllers
 *
 *  @param target        target kindof viewController
 *  @param selector      selector performed for notification
 *  @param actionHandler actionHandler performed for BOOL value change
 *
 *  @warning             selector and actionHandler should be the same
 */

//- (void)addObserver: (__kindof UIViewController *)target forSelector: (SEL)selector actionHandler: (void(^)())actionHandler;

/**
 *  Finish refresh UI
 *
 *  @param target target which finish refreshing UI
 */

- (void)finishRefreshUI: (__kindof UIViewController *)target;

/**
 *  Get Boolean value wether the viewController need do refresh UI action
 *
 *  @param target target kindof viewController to handle refreshUI action
 *
 *  @return the Boolean value to indicate wether to refresh or not
 */

- (BOOL)needRefreshUI: (__kindof UIViewController *)target;

//+ (void)pushNotificationToUser: (NSString *)idStr notifyType: (notificationType)type;

@property (nonatomic, copy) NSString *notificationBubbleValue;

- (void)getUnreadNotificationCountAndSet: (UITabBarItem *)item;

- (void)clearUnreadNotificationCountAndSet: (UITabBarItem *)item;

@end
