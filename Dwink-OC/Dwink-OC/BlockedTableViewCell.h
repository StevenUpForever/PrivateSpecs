//
//  BlockedTableViewCell.h
//  Dwink
//
//  Created by Steven Jia on 9/15/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomButton;
@class UserInfo;
@protocol blockUserProtocol <NSObject>

- (void)didClickUnblockUserButton: (CustomButton *)sender userInfo: (UserInfo *)userInfo;

@end

@interface BlockedTableViewCell : UITableViewCell

@property (nonatomic) UserInfo *userInfo;

@property (weak, nonatomic) id<blockUserProtocol> delegate;

- (void)loadData: (UserInfo *)info;

@end
