//
//  MentionTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 9/19/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfo;

@interface MentionTableViewCell : UITableViewCell

@property (nonatomic) UserInfo *userInfo;

- (void)loadData:(UserInfo *)userInfo;

@end
