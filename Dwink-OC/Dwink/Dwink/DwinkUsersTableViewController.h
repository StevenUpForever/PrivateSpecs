//
//  DwinkUsersTableViewController.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, userListTableViewType) {
    userListTableViewTypeFollowings,
    userListTableViewTypeFollowers,
    userListTableViewTypeAllUsers,
    userListTableViewTypeLikes,
    userListTableViewTypeMentions,
    userListTableViewTypeFBFriends
};

@class UserInfo;
@protocol mentionCellDelegate <NSObject>

- (void)didFinishGotMentionUserName: (UserInfo *)userInfo;

@end

@interface DwinkUsersTableViewController : UITableViewController

@property (weak, nonatomic) id<mentionCellDelegate> mentionDelegate;

/**
 *  Set up userInfo object to use and related type to prepare UI
 *
 *  @warning        must call after initialize and before show this viewController
 *
 *  @param userInfo userInfo Object to prepare for dataSource
 *  @param type     enumration type to prepare UI by usage
 */

- (void)setUpUserInfo: (UserInfo *)userInfo type: (userListTableViewType)type;

@end
