//
//  SocialTableViewConfigure.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/23/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCellViewModel.h"

@class UserInfo;
@interface SocialTableViewConfigure : NSObject

/**
 *  Reigster tableView with onImage/oneImage/oneLineImages/twoLinesImages tableViewCell
 *
 *  @param tableView the tableView which to register related Nib file
 */

+ (void)registerAllKindsOfPostTableViewCell: (UITableView *)tableView;

/**
 *  Reuse the indicate type of UITableViewCell for tableView, no data load in the method
 *
 *  @param userInfo        The userInfo Object to allocate related cell
 *  @param tableView       the tableView whcih to reuse indicated UITableViewCell
 *  @param delegate        The delegate object which handle imageView click event
 *
 *  @return the proper kind of UITableViewCell
 */

+ (__kindof UITableViewCell *)reuseDifferentTableViewCell: (UserInfo *)userInfo tableView: (UITableView *)tableView delegate: (id<CellDelegate>)delegate;

+ (__kindof UITableViewCell *)reuseDifferentTableViewCellForUserInfoPage: (UserInfo *)userInfo tableView: (UITableView *)tableView delegate: (id<CellDelegate>)delegate;

@end
