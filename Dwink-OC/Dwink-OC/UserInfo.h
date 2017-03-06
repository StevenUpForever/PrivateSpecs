//
//  SharedUserInfo.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/16.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;
@interface UserInfo : NSObject

/**
 *  Sigleton instance of SharedUserInfo which shared the same object information
 *
 *  @return object of SharedUserInfo
 */

+ (instancetype)sharedInstance;

/**
 *  User post text
 */

@property (nonatomic, readonly, copy) NSString *bio;

@property (nonatomic, readonly, copy) NSString *email;

/**
 *  User's number of followers
 */

@property (nonatomic, readonly, assign) NSUInteger followersCount;

/**
 *  User's number of following users
 */

@property (nonatomic, readonly, assign) NSInteger followingCount;

@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, readonly, copy) NSString *fullName;

/**
 *  User id of NSString type
 */

@property (nonatomic, readonly, copy) NSString *idStr;

/**
 *  Boolean value if user is currently following this one
 */

@property (nonatomic, assign) BOOL isFollowing;

/**
 *  Boolean value if this is the current user
 */

@property (nonatomic, readonly, assign) BOOL isSelf;

/**
 *  Number of all posts of current user
 */

@property (nonatomic, readonly, assign) NSUInteger postCount;

/**
 *  NSString type of profile image url
 */

@property (nonatomic, readonly, copy) NSString *profileImageUrlStr;

/**
 *  Points got by the user
 */

@property (nonatomic, readonly, assign) NSInteger points;


/**
 Boolean value indicate if the user is blocked by current user
 */
@property (nonatomic, readonly, assign) BOOL isBlocked;

/**
 Boolean value indicate wether the current user's profile is private to others
 */
@property (nonatomic, readonly, assign) BOOL privateProfile;

@property (nonatomic, assign) BOOL isPending;

/**
 unread notifications count
 */
@property (nonatomic, readonly, assign) NSUInteger unreadNotifyCount;

/**
 current user's fb id, nil if not registed from fb
 */
@property (nonatomic, copy) NSString *fbId;

/**
 *  Post object of this userInfo
 */

@property (nonatomic, readonly) Post *post;

/**
 *  Load data from JSON callback
 *
 *  @param obj response Object from API call, normally be JSON obejct
 */

- (void)loadResponseObj: (id)obj;

/**
 *  Reset sharedInstance when logout to prevent error between two login users
 */

- (void)resetSharedInstance;

@end


@interface Post : NSObject

/**
 *  Number of comments in current post
 */

@property (nonatomic, readonly, assign) NSUInteger post_commentsCount;

/**
 *  The time when this post is created by NSString type
 */

@property (nonatomic, readonly, copy) NSDate *createTime;

/**
 *  Id string of this post
 */

@property (nonatomic, readonly, copy) NSString *postIdString;

/**
 *  Images url string contained in this post (normal size)
 */

@property (nonatomic, readonly, copy) NSArray *imageURLStrArray;

/**
 *  Boolean value if user is liked the current post
 */

@property (nonatomic, readonly, assign) BOOL isLiked;

/**
 *  Change like status after call like/unlike API in model
 *
 *  @param liked like boolean parameter to pass into model
 */

- (void)changeLikeStatus: (BOOL)liked;

/**
 *  Number of likes of this post
 */

@property (nonatomic, readonly, assign) NSUInteger likesCount;

/**
 *  The text in current post
 */

@property (nonatomic, readonly, copy) NSString *postText;

/**
 *  Video url string in this post, can be only one
 */

@property (nonatomic, readonly, copy) NSString *videoURLString;

/**
 *  Load post data from dictionary
 *
 *  @param postDict post data source NSDictionary
 */

- (void)loadPostDict: (NSDictionary *)postDict;

@end


