//
//  SuperPostTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "HomeTableViewNoImageCell.h"
#import "HomeCellViewModel.h"
#import "UserInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeTableViewNoImageCell()

@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *name;
@property (nonatomic) UILabel *username;
@property (nonatomic) UILabel *text;
@property (nonatomic) UILabel *likeLabel;
@property (nonatomic) UILabel *commentLabel;
@property (nonatomic) UILabel *elapsed;
@property (nonatomic) UIButton *likeButton;
@property (nonatomic) UIButton *commentButton;
@property (nonatomic) UIImageView *actionMenuImageView;

@property (nonatomic) MASConstraint *avatarWidth;
@property (nonatomic) MASConstraint *actionHeight;
@property (nonatomic) MASConstraint *nameHeight;
@property (nonatomic) MASConstraint *usernameHeight;

@end

@implementation HomeTableViewNoImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
        [self makeLayoutsForSubviews];
        
        self.viewModel = [[HomeCellViewModel alloc]init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.viewModel addGestureForActionMenu:self.actionMenuImageView];
        
        //ContentView frame width is 320 when first show not the screen with until reuse it once, so set screen width to contenView when initialize
        CGRect frame = self.contentView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
        self.contentView.frame = frame;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadCellDataWithInfo: (UserInfo *)info {
    [self.viewModel loadUserInfo:info];
    
    [self.avatarImageView sd_setImageWithURL:self.viewModel.profileURL placeholderImage:self.viewModel.profilePlaceHolder options:SDWebImageRefreshCached];
    self.name.text = self.viewModel.fullname;
    self.username.text = self.viewModel.username;
    self.text.text = self.viewModel.text;
    self.likeLabel.text = self.viewModel.likesCountString;
    self.commentLabel.text = self.viewModel.commentsCountString;
    self.elapsed.text = self.viewModel.elapsed;
    [self.likeButton setImage:self.viewModel.likeImage forState:UIControlStateNormal];
    [self.viewModel commentButtonAction:self.commentButton];
}

- (void)likeAction:(UIButton *)sender {
    [self.viewModel likePostWithUIUpdate:^(BOOL liked) {
        if (liked) {
            self.likeLabel.text = self.viewModel.likesCountString;
            [self.likeButton setImage:[UIImage imageNamed:@"likedFilled"] forState:UIControlStateNormal];
        } else {
            self.likeLabel.text = self.viewModel.likesCountString;
            [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Private methods

- (void)addSubviews {
    _avatarImageView = [[UIImageView alloc]init];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.image = [UIImage imageNamed:@"penguin"];
    self.avatarImageView.layer.cornerRadius = 25.0;
    [self.contentView addSubview:self.avatarImageView];
    
    _name = [[UILabel alloc]init];
    self.name.font = [self.name.font fontWithSize:18.0];
    self.name.text = @"name";
    self.name.textColor = [UIColor DwinkRed];
    [self.contentView addSubview:self.name];
    
    _username = [[UILabel alloc]init];
    self.username.font = [self.username.font fontWithSize:15.0];
    self.username.text = @"username";
    self.username.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.username];
    
    _text = [[UILabel alloc]init];
    self.text.font = [self.text.font fontWithSize:15.0];
    self.text.numberOfLines = 0;
    [self.contentView addSubview:self.text];
    
    _likeLabel = [[UILabel alloc]init];
    self.likeLabel.font = [self.likeLabel.font fontWithSize:15.0];
    self.likeLabel.adjustsFontSizeToFitWidth = YES;
    self.likeLabel.text = @"0";
    self.likeLabel.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.likeLabel];
    
    _commentLabel = [[UILabel alloc]init];
    self.commentLabel.font = [self.commentLabel.font fontWithSize:15.0];
    self.commentLabel.adjustsFontSizeToFitWidth = YES;
    self.commentLabel.text = @"0";
    self.commentLabel.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.commentLabel];
    
    _elapsed = [[UILabel alloc]init];
    self.elapsed.font = [self.elapsed.font fontWithSize:15.0];
    self.elapsed.text = @"0 minute ago";
    self.elapsed.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.elapsed];
    
    _likeButton = [[UIButton alloc]init];
    [self.likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    _commentButton = [[UIButton alloc]init];
    [self.commentButton setImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateNormal];
    
    [self.contentView addSubview:self.commentButton];
    
    _actionMenuImageView = [[UIImageView alloc]init];
    self.actionMenuImageView.contentMode = UIViewContentModeCenter;
    self.actionMenuImageView.image = [UIImage imageNamed:@"ic_more_vert"];
    self.actionMenuImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.actionMenuImageView];
    
    _postView = [[UIView alloc]init];
    [self.contentView addSubview:self.postView];
}

- (void)makeLayoutsForSubviews {
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
        self.avatarWidth = make.width.mas_equalTo(50.0);
        make.height.equalTo(self.avatarImageView.mas_width).multipliedBy(1.0/1.0);
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).with.offset(8.0);
        make.top.equalTo(self.contentView.mas_top).with.offset(8.0);
        make.bottom.equalTo(self.username.mas_top).offset(2.0);
        make.trailing.equalTo(self.actionMenuImageView.mas_leading).offset(-8.0);
        self.nameHeight = make.height.mas_equalTo(22.0);
    }];
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.trailing.equalTo(self.actionMenuImageView.mas_leading).offset(-8.0);
        self.usernameHeight = make.height.mas_equalTo(18.0);
    }];
    [self.actionMenuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        make.width.equalTo(self.avatarImageView.mas_width).multipliedBy(4.0/5.0);
        self.actionHeight = make.height.equalTo(self.avatarImageView.mas_height).multipliedBy(4.0/5.0);
    }];
    [self.text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionMenuImageView.mas_bottom).offset(8.0);
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.bottom.equalTo(self.postView.mas_top).offset(-8.0);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
    }];
    [self.postView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        self.postViewHeight = make.height.mas_equalTo(0.0);
        make.bottom.equalTo(self.likeButton.mas_top).offset(-8.0);
    }];
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.postView.mas_leading).offset(0.0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8.0);
        make.height.mas_equalTo(25.0);
        make.height.equalTo(self.likeButton.mas_width).multipliedBy(1.0/1.0);
        make.trailing.equalTo(self.likeLabel.mas_leading).offset(-8.0);
    }];
    [self.likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.likeButton);
        make.centerY.equalTo(self.likeButton);
        make.width.mas_equalTo(45.0);
    }];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.likeLabel.mas_trailing).offset(8.0);
        make.centerY.equalTo(self.likeButton);
        make.width.equalTo(self.likeButton);
        make.height.equalTo(self.likeButton);
        make.trailing.equalTo(self.commentLabel.mas_leading).offset(-8.0);
    }];
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.likeButton);
        make.centerY.equalTo(self.likeButton);
    }];
    [self.elapsed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.likeButton);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
    }];
}

- (void)hidePublicInforUI {
    self.avatarImageView.hidden = YES;
    self.name.text = nil;
    self.username.text = nil;
    self.commentLabel.hidden = YES;
    self.commentButton.hidden = YES;
    self.avatarWidth.mas_equalTo(0.0);
    self.actionHeight.mas_equalTo(0.0);
    self.nameHeight.mas_equalTo(0.0);
    self.usernameHeight.mas_equalTo(0.0);
    self.actionMenuImageView.image = nil;
    self.actionMenuImageView.userInteractionEnabled = NO;
    [self.viewModel addLikesGesture:self.likeLabel];
}

@end
