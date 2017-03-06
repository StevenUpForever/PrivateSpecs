//
//  PublicAPI.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/16.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CommonAPI.h"
#import "UserInfoNotification.h"

@class UserInfo;
@class CommentModel;
@class BulletinModel;
typedef void(^userInfoArrayHandler)(NSArray<UserInfo *> *userInfoArray);

@interface SocialAPI : CommonAPI

#pragma mark - initializations

/**
 *  Custom initialization method of SocialAPI class, used in followings and followers page
 *
 *  @param idStr  id string to use for followings and followers API
 *  @param isSelf isSelf to use for current followings/followers or someone's followings/followers API
 *  @warning      must used in followings/followers/Likes page
 *
 *  @return instance of SocialAPI class
 */

- (instancetype)initWithIdStr: (NSString *)idStr isSelf: (BOOL)isSelf;

@property (nonatomic) NSURLSessionDataTask *currentDataTask;

#pragma mark - HomeTableView API

/**
 *  Reset home feed URL String
 */

- (void)resetHomeFeedString;

/**
 *
 *
 *  @return wether there's no more feed data
 */

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreHomeFeeds;

/**
 *  Get Home feed API inclue self than followings API
 *
 *  @param successHandler callback when successfully get all users information, parameter is array of userInfo obejcts
 *  @param failureHandler callback when failed get all users information with error message
 */

- (void)getHomeFeedWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

#pragma mark - Bulletin API

- (void)resetNotificationURLString;

@property (nonatomic, assign) BOOL noMoreNotifications;

/**
 *  API when got notification to update user's feeds
 *
 *  @param successHandler callback when successfully get notifications
 *  @param failureHandler callback when failed get notifications
 */

- (void)getNotificationsWithSuccessHandler: (void(^)(NSArray<BulletinModel *> *bulletinArray))successHandler failureHandler: (errorMessageHandler)failureHandler;

#pragma mark - find user API

/**
 *  Reset all user API endpoint when need refresh all user list
 */

- (void)resetAllUserString;

/**
 *
 *
 *  @return Boolean value indicate wether there will be more users in all user list
 */

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreAllUsers;

/**
 *  Get all users API
 *
 *  @param successHandler callback when successfully get all users information, parameter is array of userInfo obejcts
 *  @param failureHandler   callback when failed get all users information with error message
 */

- (void)getAllUsersWithSuccessBlock:(userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;


/**
 Reset search all users url string

 @param searchText search text to search
 */
- (void)resetSearchedUsersStringWithSearchText: (NSString *)searchText;


/**
 Boolean value indicate wether there's more searched users to show
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreSearchedUsers;

/**
 *  Get searched user list
 *
 *  @param searchText     search text to search, usually email/username/name
 *  @param successHandler callback when successfully get user list
 *  @param failureHandler callback when falied get user list
 */

- (void)getSearchedUserList: (NSString *)searchText successHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Reset get FB users API url string

 @param fbId fb id need to get fb friends
 */
- (void)resetGetFBFriendsURLStringWithFBId: (NSString *)fbId;

/**
 Boolean value indicate if there's any more fb friends
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreFBFriends;

/**
 Get fb friends API of current user

 @param successHandler callback when succesfully get fb friends
 @param failureHandler callback when failed get fb friends
 */
- (void)getFBFriendsWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

#pragma mark - UserInfo API

/**
 *  Reset user followings endpoint to first page
 *
 *  @param idStr  idStr when use reset someone's followings
 *  @param isSelf isSelf to indicate someone's followings
 */

- (void)resetFollowingString: (NSString *)idStr isSelf: (BOOL)isSelf;

/**
 *
 *
 *  @return Boolean value indicate wether there will be no more users in following user list
 */

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreFollowingUsers;

/**
 *  Get user followings API
 *
 *  @param successHandler callback when successfully get following users information, parameter is array of userInfo obejcts
 *  @param failureHandler   callback when failed get following users information with error message
 */
- (void)getWhoTheUserIsFollowingWithSuccessBlock:(userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;


/**
 Reset following searched user url string for mention list

 @param idString id string to indicate user
 @param searchText search text to search users
 */
- (void)resetFollowingSearchedURLString:(NSString *)idString searchText: (NSString *)searchText;


/**
 Boolean value indicate wether there's more following searched users
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreFollowingSearchedUsers;

/**
 *  Get following searched users API
 *
 *  @param text the text to search
 *  @param successHandler callback when successfully get following searched users information, parameter is array of userInfo obejcts
 *  @param failureHandler   callback when failed get following searched users information with error message
 */
- (void)getFollowingSearchedUsersWithText: (NSString *)text successHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  Reset user followings endpoint to first page
 *
 *  @param idStr  idStr when use reset someone's followers
 *  @param isSelf isSelf to indicate someone's followers
 */

- (void)resetFollowersString: (NSString *)idStr isSelf: (BOOL)isSelf;

/**
 *
 *
 *  @return Boolean value indicate wether there will be no more users in followers list
 */

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreFollowers;

/**
 *  Get User's followers API
 *
 *  @param successHandler callback when successfully get all users information, parameter is array of userInfo obejcts
 *  @param failureHandler callback when failed get all users information with error message
 */

- (void)getUserFollowersWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Boolean value indicate wether there will be no more comments
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreComments;


/**
 Reset comment endpoint to first page
 
 @param idStr id string to indicate user whom to fetch comments
 */
- (void)resetCommentsURLStringWithIdStr: (NSString *)idStr;

/**
 *  Get comment by user id string
 *
 *  @param idStr          id string to locate which user's comment to fetch
 *  @param successHandler callback when successfully get commnets of Array of CommentModel objects
 *  @param failureHandler callback when failed to get comments from user
 */

- (void)getCommentsWithSuccessHandler: (void(^)(NSArray<CommentModel *> *commentArray))successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 *  reset url string of get likes API
 *
 *  @param idStr idString which to reset to
 */

- (void)resetLikesURLStrWithIdStr: (NSString *)idStr;

/**
 *  wether there's no more likes to show
 *
 *  @return Boolean value to show wether there's no more likes
 */

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreLikesUsers;

/**
 *  Get likes user list by id string
 *
 *  @param idStr          id string locate which user's post likes to fetch
 *  @param successHandler callback when successfully get likes user list
 *  @param failureHandler callback when failed get likes user list
 */

- (void)getLikes: (NSString *)idStr successHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

/**
 Reset block user API string
 */
- (void)resetBlockedUserURLStr;

/**
 Boolean value indicate if there's anymore blocked users
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMoreBlockedUsers;

/**
 Get Unblock users API
 
 @param successHandler callback when successfully  get unblock users
 @param failureHandler callback when failed to  get unblock users
 */
- (void)getBlockUserListWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

- (void)resetPendingRequestsURLStr;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL noMorePendingRequests;

- (void)getPendingRequestsWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler;

@end
