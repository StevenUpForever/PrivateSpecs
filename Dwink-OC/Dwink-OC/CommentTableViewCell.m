//
//  CommentTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIKitCategories.h"
#import "Masonry.h"
#import "UserInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CommentTableViewCell()

@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *commentLabel;
@property (nonatomic) UILabel *editableCommentLabel;
@property (nonatomic) UILabel *elapsedLabel;

@end

@implementation CommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initializeSubviewLayouts];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadData: (CommentModel *)model {
    
    _model = model;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.userInfo.profileImageUrlStr] placeholderImage:[UIImage defaultCharacterImage:model.userInfo.fullName] options:SDWebImageRefreshCached];
    
    self.nameLabel.text = model.userInfo.fullName;
    
    NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc]init];
    if (model.mentionStr) {
        NSAttributedString *mentionStr = [[NSAttributedString alloc]initWithString:model.mentionStr attributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}];
        [totalStr appendAttributedString:mentionStr];
    }
    if (model.commentStr) {
        NSAttributedString *commentStr = [[NSAttributedString alloc]initWithString:model.commentStr attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        [totalStr appendAttributedString:commentStr];
    }
    self.commentLabel.attributedText = totalStr;
    if (model.mentionStr.length == 0) {
        self.editableCommentLabel.text = nil;
        self.editableCommentLabel.userInteractionEnabled = NO;
    } else {
        self.editableCommentLabel.text = model.mentionStr;
        self.editableCommentLabel.userInteractionEnabled = YES;
    }
    self.elapsedLabel.text = model.elapsed;
}

#pragma mark - Custom Selectors

- (void)commentTransitionToUserInfo:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(commentCellAvatarLabelClicked:)]) {
        [self.delegate commentCellAvatarLabelClicked:self.model.userInfo];
    }
}

- (void)mentionUserTransition: (UILongPressGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(commentCellAvatarLabelClicked:)]) {
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
                sender.view.backgroundColor = [UIColor selectionGrey];
                break;
            default:
                sender.view.backgroundColor = [UIColor clearColor];
                [self.delegate commentCellAvatarLabelClicked:self.model.mentionedUser];
                break;
        }
    }
}

#pragma mark - Private methods

- (void)initializeSubviewLayouts {
    _avatarImageView = [[UIImageView alloc]init];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25.0;
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTransitionToUserInfo:)]];
    [self.contentView addSubview:self.avatarImageView];
    
    _nameLabel = [[UILabel alloc]init];
    self.nameLabel.textColor = [UIColor DwinkRed];
    self.nameLabel.font = [self.nameLabel.font fontWithSize:18.0];
    [self.contentView addSubview:self.nameLabel];
    
    _commentLabel = [[UILabel alloc]init];
    self.commentLabel.font = [self.commentLabel.font fontWithSize:15.0];
    self.commentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.commentLabel];
    
    _editableCommentLabel = [[UILabel alloc]init];
    self.editableCommentLabel.font = [self.editableCommentLabel.font fontWithSize:15.0];
    self.editableCommentLabel.textColor = [UIColor DwinkRed];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mentionUserTransition:)];
    longPress.minimumPressDuration = 0.0;
    [self.editableCommentLabel addGestureRecognizer:longPress];
    [self.contentView insertSubview:self.editableCommentLabel aboveSubview:self.commentLabel];
    
    _elapsedLabel = [[UILabel alloc]init];
    self.elapsedLabel.font = [self.elapsedLabel.font fontWithSize:15.0];
    self.elapsedLabel.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.elapsedLabel];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(50.0);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
    }];
    [self.elapsedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
    }];
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8.0);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8.0);
    }];
    [self.editableCommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8.0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8.0);
    }];
}

@end
