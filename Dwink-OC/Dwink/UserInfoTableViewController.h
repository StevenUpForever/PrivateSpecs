//
//  UserInfoTableViewController.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInformationViewModel.h"

@class UserInfo;
@interface UserInfoTableViewController : UITableViewController

@property (nonatomic) UserInformationViewModel *viewModel;

/**
 *  @warning        Must call before push viewController or perform Segue
 *
 *  @param userInfo Object of UserInfo to load UI
 *  @param type     type to identify where is this userInfoVC prepare for refresh UI after submit new Post
 */
- (void)setUp: (UserInfo *)userInfo type: (userInfoVCType)type;

@end
