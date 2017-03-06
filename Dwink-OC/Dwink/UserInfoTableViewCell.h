//
//  UserInfoTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfo;
@interface UserInfoTableViewCell : UITableViewCell

- (void)loadDataWithInfo: (UserInfo *)info;

@end
