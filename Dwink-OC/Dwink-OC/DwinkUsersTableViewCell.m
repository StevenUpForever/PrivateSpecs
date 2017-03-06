//
//  DwinkUsersTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "DwinkUsersTableViewCell.h"
#import "UserInfo.h"
#import "UIKitCategories.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DwinkUsersTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end

@implementation DwinkUsersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2.0;
    self.button.layer.cornerRadius = self.button.frame.size.width/2.0;
}

- (void)loadUserData: (UserInfo *)info {
    self.userInfo = info;
    _userID = info.idStr;
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:info.profileImageUrlStr] placeholderImage:[UIImage defaultCharacterImage:info.fullName] options:SDWebImageRefreshCached];
    
    self.userName.text = info.userName;
    self.name.text = info.fullName;
    if (info.isSelf) {
        self.button.backgroundColor = [UIColor DwinkRed];
        [self.button setImage:[UIImage imageNamed:@"penIcon30"] forState:UIControlStateNormal];
    } else if (info.isFollowing) {
        self.button.backgroundColor = [UIColor whiteColor];
        [self.button setImage:[UIImage imageNamed:@"userFollowed"] forState:UIControlStateNormal];
    } else if (info.isPending) {
        self.button.backgroundColor = [UIColor whiteColor];
        [self.button setImage:[UIImage imageNamed:@"pending"] forState:UIControlStateNormal];
    } else {
        self.button.backgroundColor = [UIColor whiteColor];
        [self.button setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
    }
    
    self.button.hidden = info.isSelf ? YES : NO;
}

@end
