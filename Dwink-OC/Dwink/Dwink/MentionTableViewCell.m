//
//  MentionTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 9/19/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "MentionTableViewCell.h"
#import "UserInfo.h"
#import "UIKitCategories.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MentionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation MentionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2.0;
    [super layoutIfNeeded];
}

- (void)loadData:(UserInfo *)userInfo {
    self.userInfo = userInfo;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.profileImageUrlStr] placeholderImage:[UIImage defaultCharacterImage:userInfo.fullName] options:SDWebImageRefreshCached];
    self.usernameLabel.text = userInfo.fullName;
}

@end
