//
//  DwinkUsersTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowButton.h"

@class UserInfo;
@interface DwinkUsersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet FollowButton *button;

@property (nonatomic, readonly) NSString *userID;

@property (nonatomic) UserInfo *userInfo;

- (void)loadUserData: (UserInfo *)info;

@end
