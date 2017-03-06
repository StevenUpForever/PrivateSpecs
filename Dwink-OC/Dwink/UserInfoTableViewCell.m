//
//  UserInfoTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserInfoTableViewCell.h"
#import "UserInfo.h"
#import "FoundationCategories.h"
#import "UIKitCategories.h"
#import "FollowButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserInfoTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *profileContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FollowButton *modifyButton;
@property (weak, nonatomic) IBOutlet UILabel *userNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@property (weak, nonatomic) IBOutlet UILabel *postNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsTextLabel;
@property (weak, nonatomic) IBOutlet UIView *pointsView;

@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UIView *followersView;
@property (weak, nonatomic) IBOutlet UILabel *followersTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingTextLabel;
@property (weak, nonatomic) IBOutlet UIView *followingView;

@end

@implementation UserInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0;
    self.modifyButton.layer.cornerRadius = self.modifyButton.layer.frame.size.width/2.0;
    self.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, self.contentView.bounds.size.width);
}

- (void)loadDataWithInfo: (UserInfo *)info {
    self.bioLabel.text = info.bio;
    self.followersLabel.text = [NSString properStringWithInteger:info.followersCount];
    self.followingLabel.text = [NSString properStringWithInteger:info.followingCount];
    self.userNamelabel.text = info.userName;
    self.postNumLabel.text = [NSString properStringWithInteger:info.points];
    if (info.profileImageUrlStr.length != 0) {
        NSURL *url = [NSURL URLWithString:info.profileImageUrlStr];
        if (url) {
            [self.profileImageView sd_setImageWithURL:url placeholderImage:[UIImage defaultCharacterImage:info.fullName] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    CGFloat minEdge = MIN(self.profileImageView.image.size.width, self.profileImageView.image.size.height);
                    self.profileImageView.image = [image imageByCroppingImageToSize:CGSizeMake(minEdge, minEdge)];
                }
            }];
        }
    } else {
        self.profileImageView.image = [UIImage defaultCharacterImage:info.fullName];
    }
    if (info.isSelf) {
        self.modifyButton.backgroundColor = [UIColor DwinkRed];
        [self.modifyButton setImage:[UIImage imageNamed:@"penIcon30"] forState:UIControlStateNormal];
    } else if (info.isFollowing) {
        self.modifyButton.backgroundColor = [UIColor whiteColor];
        [self.modifyButton setImage:[UIImage imageNamed:@"userFollowed"] forState:UIControlStateNormal];
    } else if (info.isPending) {
        self.modifyButton.backgroundColor = [UIColor whiteColor];
        [self.modifyButton setImage:[UIImage imageNamed:@"pending"] forState:UIControlStateNormal];
    } else {
        self.modifyButton.backgroundColor = [UIColor whiteColor];
        [self.modifyButton setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
    }
    if (!info.isSelf && !info.isFollowing && info.privateProfile) {
        [self privateUI];
    }
}

- (void)privateUI {
    self.pointsView.userInteractionEnabled = NO;
    self.followersView.userInteractionEnabled = NO;
    self.followingView.userInteractionEnabled = NO;
    self.pointsTextLabel.textColor = [UIColor DwinkGrey];
    self.followersTextLabel.textColor = [UIColor DwinkGrey];
    self.followingTextLabel.textColor = [UIColor DwinkGrey];
}

@end
