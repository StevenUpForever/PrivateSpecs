//
//  PendingRequestsTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 10/30/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "PendingRequestsTableViewCell.h"
#import "UserInfo.h"
#import "UIKitCategories.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PendingRequestsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (nonatomic) UserInfo *userInfo;

@end

@implementation PendingRequestsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
}

- (void)loadData: (UserInfo *)userInfo {
    self.userInfo = userInfo;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.profileImageUrlStr] placeholderImage:[UIImage defaultCharacterImage:userInfo.fullName] options:SDWebImageRefreshCached];
    self.usernameLabel.text = userInfo.userName;
    self.nameLabel.text = userInfo.fullName;
}

@end
