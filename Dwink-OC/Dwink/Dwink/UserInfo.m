//
//  SharedUserInfo.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/16.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "UserInfo.h"
#import "FoundationCategories.h"

@interface UserInfo()

@end

@implementation UserInfo

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UserInfo *userInfo;
    dispatch_once(&onceToken, ^{
        userInfo = [[UserInfo alloc]init];
    });
    return userInfo;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _post = [[Post alloc]init];
    }
    return self;
}

- (void)loadResponseObj: (id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"bio"] != [NSNull null]) {
            _bio = obj[@"bio"];
        }
        _email = obj[@"email"];
        _followersCount = [obj[@"followers_count"]unsignedIntegerValue];
        _followingCount = [obj[@"following_count"]unsignedIntegerValue];
        _fullName = obj[@"fullname"];
        _idStr = obj[@"id"];
        _isFollowing = [obj[@"is_following"]boolValue];
        _isSelf = [obj[@"is_self"]boolValue];
        _points = [obj[@"points"]unsignedIntegerValue];
        _postCount = [obj[@"post_count"]unsignedIntegerValue];
        if (obj[@"profile_img"] != [NSNull null]) {
            _profileImageUrlStr = obj[@"profile_img"];
        }
        _userName = obj[@"username"];
        _isBlocked = [obj[@"is_blocked"]boolValue];
        
        if ([obj[@"post"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *postDict = obj[@"post"];
            [self.post loadPostDict:postDict];
        }
        _privateProfile = [obj[@"private"]boolValue];
        _isPending = [obj[@"is_pending"]boolValue];
        _unreadNotifyCount = [obj[@"unread_notification_count"]unsignedIntegerValue];
        if (obj[@"facebook_id"] != [NSNull null]) {
            _fbId = obj[@"facebook_id"];
        }
    }
}

- (void)resetSharedInstance {
    if ([self isEqual:[UserInfo sharedInstance]]) {
        _bio = nil;
        _email = nil;
        _followersCount = 0;
        _followingCount = 0;
        _userName = nil;
        _fullName = nil;
        _idStr = nil;
        _isFollowing = NO;
        _isSelf = NO;
        _postCount = 0;
        _profileImageUrlStr = nil;
        _points = 0;
        _post = [[Post alloc]init];
    }
}

@end


@implementation Post

- (void)loadPostDict: (NSDictionary *)postDict {
    _post_commentsCount = [postDict[@"comments_count"]unsignedIntegerValue];
    _createTime = postDict[@"created"];
    
    if (postDict[@"created"] != [NSNull null]) {
        _createTime = [postDict[@"created"] convertISO8601String];
    }
    
    _postIdString = postDict[@"id"];
    
    NSArray *imageArray = postDict[@"images"];
    if ([imageArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempImages = [[NSMutableArray alloc]init];
        for (NSString *urlString in imageArray) {
            [tempImages addObject:urlString];
        }
        _imageURLStrArray = tempImages;
    }
    
    _isLiked = [postDict[@"is_liked"]boolValue];
    _likesCount = [postDict[@"likes_count"]unsignedIntegerValue];
    if (postDict[@"text"] != [NSNull null]) {
        _postText = postDict[@"text"];
    }
    if (postDict[@"video"] != [NSNull null]) {
        _videoURLString = postDict[@"video"];
    }
}

- (void)changeLikeStatus: (BOOL)liked {
    _isLiked = liked;
    _likesCount = liked ? self.likesCount + 1 : self.likesCount - 1;
}

@end

