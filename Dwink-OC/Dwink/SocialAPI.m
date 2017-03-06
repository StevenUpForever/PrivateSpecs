//
//  PublicAPI.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/16.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "SocialAPI.h"
#import "UserInfo.h"
#import "BulletinModel.h"
#import "ImageManager.h"
#import "ImageAPI.h"
#import "FoundationCategories.h"
#import "CommentModel.h"
#import "SocialAPI+UnpagedAPICategory.h"

typedef NS_ENUM(NSUInteger, userInfoArrayAPIType) {
    userInfoArrayAPITypeHomeFeed,
    userInfoArrayAPITypeFollowings,
    userInfoArrayAPITypeFollowingSearchedUsers,
    userInfoArrayAPITypeFollowers,
    userInfoArrayAPITypeAllUsers,
    userInfoArrayAPITypeLikes,
    userInfoArrayAPITypeSearchedUsers,
    userInfoArrayAPITypeBlockedUsers,
    userInfoArrayAPITypeNotifications,
    userInfoArrayAPITypeComments,
    userInfoArrayAPITypeFBFriends,
    userInfoArrayAPITypePendingRequests
};

@interface SocialAPI()

@property (nonatomic, copy) NSString *homeFeedURLString;
@property (nonatomic, copy) NSString *searchedURLString;
@property (nonatomic, copy) NSString *notificationURLString;
@property (nonatomic, copy) NSString *followingsURLString;
@property (nonatomic, copy) NSString *followingSearchedURLString;
@property (nonatomic, copy) NSString *followersURLString;
@property (nonatomic, copy) NSString *likesURLString;
@property (nonatomic, copy) NSString *blockedUserURLString;
@property (nonatomic, copy) NSString *commentURLString;
@property (nonatomic, copy) NSString *allUserURLString;
@property (nonatomic, copy) NSString *fbFriendsURLString;
@property (nonatomic, copy) NSString *pendingRequestsURLString;

@end

@implementation SocialAPI

- (instancetype)initWithIdStr: (NSString *)idStr isSelf: (BOOL)isSelf
{
    self = [super init];
    if (self) {
        [self resetHomeFeedString];
        [self resetAllUserString];
        [self resetBlockedUserURLStr];
        [self resetFollowingString:idStr isSelf:isSelf];
        [self resetFollowersString:idStr isSelf:isSelf];
        [self resetLikesURLStrWithIdStr:idStr];
        [self resetCommentsURLStringWithIdStr:idStr];
        [self resetNotificationURLString];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetHomeFeedString];
        [self resetAllUserString];
        [self resetBlockedUserURLStr];
        [self resetNotificationURLString];
    }
    return self;
}

#pragma mark - HomeTableView API

- (void)resetHomeFeedString {
    self.homeFeedURLString = [NSString stringWithFormat:@"%@/user/feed?page=1", mainEndPoint];
}

- (BOOL)noMoreHomeFeeds {
    return self.homeFeedURLString == nil;
}

- (void)getHomeFeedWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.homeFeedURLString type:userInfoArrayAPITypeHomeFeed successHandler:successHandler failureHandler:failureHandler];
}

#pragma mark - Bulletin API

- (void)resetNotificationURLString {
    self.notificationURLString = [NSString stringWithFormat:@"%@/notifications", mainEndPoint];
}

- (BOOL)noMoreNotifications {
    return self.notificationURLString == nil;
}

- (void)getNotificationsWithSuccessHandler: (void(^)(NSArray<BulletinModel *> *bulletinArray))successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.notificationURLString type:userInfoArrayAPITypeNotifications successHandler:successHandler failureHandler:failureHandler];
}


#pragma mark - find user API

- (void)resetAllUserString {
    self.allUserURLString = [NSString stringWithFormat:@"%@/users", mainEndPoint];
}

- (BOOL)noMoreAllUsers {
    return self.allUserURLString == nil;
}

- (void)getAllUsersWithSuccessBlock:(userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.allUserURLString type:userInfoArrayAPITypeAllUsers successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetSearchedUsersStringWithSearchText: (NSString *)searchText {
    self.searchedURLString = [NSString stringWithFormat:@"%@/users?query=%@", mainEndPoint, [searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
}

- (BOOL)noMoreSearchedUsers {
    return self.searchedURLString == nil;
}

- (void)getSearchedUserList: (NSString *)searchText successHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    
    [searchText createURLFullNameStringWithCompletionHandler:^(NSString *result, NSError *error) {
        if (error) {
            if (failureHandler) {
                failureHandler(@"You need to correct input");
            }
        } else {
            [self loadUsersInformationAPIWithEndpoint:self.searchedURLString type:userInfoArrayAPITypeSearchedUsers successHandler:successHandler failureHandler:failureHandler];
        }
    }];
    
}

- (void)resetGetFBFriendsURLStringWithFBId: (NSString *)fbId {
    self.fbFriendsURLString = [NSString stringWithFormat:@"%@/users?facebook_id=%@", mainEndPoint, fbId];
}

- (BOOL)noMoreFBFriends {
    return self.fbFriendsURLString == nil;
}

- (void)getFBFriendsWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.fbFriendsURLString type:userInfoArrayAPITypeFBFriends successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetFollowingString: (NSString *)idStr isSelf: (BOOL)isSelf {
    self.followingsURLString = [NSString stringWithFormat:@"%@/users/%@/following", mainEndPoint, idStr];
}

- (BOOL)noMoreFollowingUsers {
    return self.followingsURLString == nil;
}

- (void)getWhoTheUserIsFollowingWithSuccessBlock:(userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.followingsURLString type:userInfoArrayAPITypeFollowings successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetFollowingSearchedURLString:(NSString *)idString searchText: (NSString *)searchText {
    self.followingSearchedURLString = [NSString stringWithFormat:@"%@/users/%@/following?query=%@", mainEndPoint, idString, searchText];
}

- (BOOL)noMoreFollowingSearchedUsers {
    return self.followingSearchedURLString == nil;
}

- (void)getFollowingSearchedUsersWithText:(NSString *)text successHandler:(userInfoArrayHandler)successHandler failureHandler:(errorMessageHandler)failureHandler {
    [text createURLFullNameStringWithCompletionHandler:^(NSString *result, NSError *error) {
        if (error != nil) {
            if (failureHandler) {
                failureHandler(@"You need to correct search input");
            }
        } else {
            [self loadUsersInformationAPIWithEndpoint:self.followingSearchedURLString type:userInfoArrayAPITypeFollowingSearchedUsers successHandler:successHandler failureHandler:failureHandler];
        }
    }];
}

- (void)resetFollowersString: (NSString *)idStr isSelf: (BOOL)isSelf {
    self.followersURLString = [NSString stringWithFormat:@"%@/users/%@/followers", mainEndPoint, idStr];
}

- (BOOL)noMoreFollowers {
    return self.followersURLString == nil;
}

- (void)getUserFollowersWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.followersURLString type:userInfoArrayAPITypeFollowers successHandler:successHandler failureHandler:failureHandler];
}

- (BOOL)noMoreComments {
    return self.commentURLString == nil;
}

- (void)resetCommentsURLStringWithIdStr:(NSString *)idStr {
    self.commentURLString = [NSString stringWithFormat:@"%@/users/%@/post/comments", mainEndPoint, idStr];
}

- (void)getCommentsWithSuccessHandler: (void(^)(NSArray<CommentModel *> *commentArray))successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.commentURLString type:userInfoArrayAPITypeComments successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetLikesURLStrWithIdStr: (NSString *)idStr {
    self.likesURLString = [NSString stringWithFormat:@"%@/users/%@/post/likes", mainEndPoint, idStr];
}

- (BOOL)noMoreLikesUsers {
    return self.likesURLString == nil;
}

- (void)getLikes: (NSString *)idStr successHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.likesURLString type:userInfoArrayAPITypeLikes successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetBlockedUserURLStr {
    self.blockedUserURLString = [NSString stringWithFormat:@"%@/blocked-users", mainEndPoint];
}

- (BOOL)noMoreBlockedUsers {
    return self.blockedUserURLString == nil;
}

- (void)getBlockUserListWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.blockedUserURLString type:userInfoArrayAPITypeBlockedUsers successHandler:successHandler failureHandler:failureHandler];
}

- (void)resetPendingRequestsURLStr {
    self.pendingRequestsURLString = [NSString stringWithFormat:@"%@/user/followers/requests", mainEndPoint];
}

- (BOOL)noMorePendingRequests {
    return self.pendingRequestsURLString == nil;
}

- (void)getPendingRequestsWithSuccessHandler: (userInfoArrayHandler)successHandler failureHandler: (errorMessageHandler)failureHandler {
    [self loadUsersInformationAPIWithEndpoint:self.pendingRequestsURLString type:userInfoArrayAPITypePendingRequests successHandler:successHandler failureHandler:failureHandler];
}

#pragma mark - private methods

- (void)loadUsersInformationAPIWithEndpoint: (NSString *)endpoint type: (userInfoArrayAPIType)type successHandler: (void(^)(id responseArray))successHandler failureHandler: (errorMessageHandler)failureHandler {
//    NSLog(@"%@", endpoint);
    __block NSString *mutableEndpoint = endpoint;
    
    if (mutableEndpoint == nil) {
        return;
    }
    
    AFHTTPSessionManager *sessionManager = [SocialAPI createTokenSessionManager];
    self.currentDataTask = [sessionManager GET:mutableEndpoint parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//         NSLog(@"%@", responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSMutableArray<UserInfo *> *userInfoArray = [[NSMutableArray alloc]init];
            NSMutableArray<BulletinModel *> *bulletinArray = [[NSMutableArray alloc]init];
            NSMutableArray<CommentModel *> *commentArray = [[NSMutableArray alloc]init];
            
            NSArray *dataArray = responseObject[@"data"];
            if ([dataArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary *detail in dataArray) {
                    if ([detail isKindOfClass:[NSDictionary class]]) {
                        switch (type) {
                            case userInfoArrayAPITypeNotifications: {
                                BulletinModel *model = [[BulletinModel alloc]init];
                                [model loadData:detail];
                                [bulletinArray addObject:model];
                                break;
                            }
                            case userInfoArrayAPITypeComments: {
                                CommentModel *comment = [[CommentModel alloc]init];
                                [comment loadData:detail];
                                [commentArray addObject:comment];
                                break;
                            }
                            default: {
                                UserInfo *userInfo = [[UserInfo alloc]init];
                                [userInfo loadResponseObj:detail];
                                [userInfoArray addObject:userInfo];
                                break;
                            }
                        }
                    } else {
                        if (failureHandler) {
                            failureHandler(@"Response data is invalid");
                        }
                    }
                }
            } else {
                if (failureHandler) {
                    failureHandler(@"Response data is invalid");
                }
            }
            if ([responseObject[@"meta"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *meta = responseObject[@"meta"];
                if ([meta[@"pagination"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *pagination = meta[@"pagination"];
                    if ([pagination[@"links"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *links = pagination[@"links"];
                        mutableEndpoint = links[@"next"];
//                        NSLog(@"%@", mutableEndpoint);
                    } else {
                        mutableEndpoint = nil;
                    }
//                    NSLog(@"%@", mutableEndpoint);
                } else {
                    mutableEndpoint = nil;
                }
            } else {
                mutableEndpoint = nil;
            }
            
            __weak SocialAPI *weakSelf = self;
            switch (type) {
                case userInfoArrayAPITypeHomeFeed: {
                    weakSelf.homeFeedURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeFollowings: {
                    _followingsURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeFollowingSearchedUsers: {
                    _followingSearchedURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeFollowers: {
                    weakSelf.followersURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeAllUsers: {
                    weakSelf.allUserURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeLikes: {
                    weakSelf.likesURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeSearchedUsers: {
                    weakSelf.searchedURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeBlockedUsers: {
                    weakSelf.blockedUserURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeNotifications: {
                    weakSelf.notificationURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeComments: {
                    weakSelf.commentURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypeFBFriends: {
                    weakSelf.fbFriendsURLString = mutableEndpoint;
                    break;
                }
                case userInfoArrayAPITypePendingRequests: {
                    weakSelf.pendingRequestsURLString = mutableEndpoint;
                    break;
                }
            }
            
            if (successHandler) {
                switch (type) {
                    case userInfoArrayAPITypeNotifications: {
                        successHandler(bulletinArray);
                        break;
                    }
                    case userInfoArrayAPITypeComments: {
                       successHandler(commentArray);
                        break;
                    }
                    default: {
                        successHandler(userInfoArray);
                        break;
                    }
                }
            }
        } else {
            if (failureHandler) {
                failureHandler(@"Response data is invalid");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
        if (error.code != NSURLErrorCancelled) {
            [SocialAPI failedHandlerManagerWithSessionManager:sessionManager task:task error:error completionHandler:^{
                [self loadUsersInformationAPIWithEndpoint:mutableEndpoint type:type successHandler:successHandler failureHandler:failureHandler];
            } failureHandler:failureHandler];
        }
    }];
    
}   

@end
