//
//  BlockedTableViewCell.m
//  Dwink
//
//  Created by Steven Jia on 9/15/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "BlockedTableViewCell.h"
#import "DesignableUIKit.h"
#import "UserInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BlockedTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet CustomButton *blockButton;
@end

@implementation BlockedTableViewCell

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
}

- (void)loadData: (UserInfo *)info {
    self.userInfo = info;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:info.profileImageUrlStr] placeholderImage:[UIImage imageNamed:@"penguin"] options:SDWebImageRefreshCached];
    self.usernameLabel.text = info.userName;
    self.nameLabel.text = info.fullName;
    
}

- (IBAction)unblockUserAction:(CustomButton *)sender {
    [self.delegate didClickUnblockUserButton:sender userInfo:self.userInfo];
}

@end
