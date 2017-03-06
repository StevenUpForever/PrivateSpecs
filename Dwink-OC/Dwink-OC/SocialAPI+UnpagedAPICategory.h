//
//  SocialAPI+SocialAPIUserInfoCategory.h
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "SocialAPI.h"

@interface SocialAPI (UnpagedAPICategory)

/**
 *  API to like someone's post
 *
 *  @param userId         the userId which to indicate which post need to like
 *  @param successHandler callback when successfully like the post
 *  @param failureHandler callback when failed to like the post
 */

+ (void)likePost: (NSString *)userId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  API to unlike someone's post
 *
 *  @param userId         the userId which to indicate which post need to unlike
 *  @param successHandler callback when successfully unlike the post
 *  @param failureHandler callback when failed to unlike the post
 */

+ (void)unLikePost: (NSString *)userId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  create new post API
 *
 *  @param text          the text posted in new post
 *  @param imageStrArray array contains all images urls in post
 *  @param video         vieo url in post
 *  @param successHandler  callback when sucessfully create post data in server
 *  @param failureHandler  callback when failed create post
 */

+ (void)createNewPostWithText: (NSString *)text imageStrArray: (NSArray *)imageStrArray video: (NSString *)video successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Follow indicate user by userId API
 *
 *  @param idStr        the user id string which to indicate user
 *  @param successHandler callback when successfully follow the user with userInfo response
 *  @param failureHandler   callback when failed to follow the user
 */

+ (void)followUser: (NSString *)idStr successHandler:(userInfoHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Unfollow indicate user by userId API
 *
 *  @param idStr        the user id string which to indicate user
 *  @param successHandler callback when successfully unfollow the user
 *  @param failureHandler   callback when failed to unfollow the user
 */

+ (void)unFollowUser: (NSString *)idStr successHandler:(blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Get Current user information API
 *
 *  @param successHandler callback when successfully get user information, parameter is sigleton of UserInfo
 *  @param failureHandler   callback when failed get user information with error message
 */

+ (void)getCurrentUserWithSuccessBlock: (void(^)(UserInfo *sharedUserInfo))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Get some indicate user information API
 *
 *  @param idStr          idStr to indicate the user
 *  @param successHandler callback when successfully get user information, parameter is one object of UserInfo
 *  @param failureHandler   callback when failed get user information with error message
 */
+ (void)getIndicateUserWithIdStr: (NSString *)idStr successHandler: (void(^)(UserInfo *userInfo))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Update user profile API
 *
 *  @param name           user's fullName
 *  @param bio            user's bio
 *  @param username       user's username
 *  @param email          user's email
 *  @param private        wether the user's profile is private to others
 *  @param unreadNotifications user's unread notification count
 *  @param successHandler callback when successfully updated user's profile
 *  @param failureHandler   callback when failed updated user's profile
 */
+ (void)updateUserProfile: (NSString *)name bio: (NSString *)bio username: (NSString *)username email: (NSString *)email private: (BOOL)private unreadNotifications: (NSInteger)unreadNotifications successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Post new comment to a id string located user
 *
 *  @param idStr          id string to locate which user to reply
 *  @param commentStr     comment string to post
 *  @param successHandler callback when successfully post a new comment
 *  @param failureHandler callback when faield post a new comment
 */
+ (void)postNewComments: (NSString *)idStr commentStr: (NSString *)commentStr successHandler: (void(^)(CommentModel *comment))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Delete new comment to a id string located user
 *
 *  @param userId         id string to locate which user to reply
 *  @param commentId      comment id indicate which comment to delete
 *  @param successHandler callback when successfully post a new comment
 *  @param failureHandler callback when faield post a new comment
 */
+ (void)deleteComment: (NSString *)userId commentId: (NSString *)commentId successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;


/**
 Report user API

 @param reason         the reason to report user
 @param idStr          id string to inidicate which user report
 @param successHandler callback when successfully report the user
 @param failureHandler callback when failed to report the user
 */
+ (void)reportUserWithReason: (NSString *)reason idStr: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Block user API

 @param idStr          id string to indicate which user to block
 @param successHandler callback when successfully block the user
 @param failureHandler callback when failed to block the user
 */
+ (void)blockUserWithId: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Unblock user API
 
 @param idStr          id string to indicate which user to unblock
 @param successHandler callback when successfully Unblock the user
 @param failureHandler callback when failed to Unblock the user
 */
+ (void)unBlockUserWithId: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

+ (void)acceptPendingRequest: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

+ (void)ignorePendingRequest: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

+ (void)cancelPendingRequestTo: (NSString *)idStr successHandler: (blankHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

@end
