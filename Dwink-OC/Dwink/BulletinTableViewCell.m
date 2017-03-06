//
//  BulletinTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "BulletinTableViewCell.h"
#import "UIKitCategories.h"
#import "Masonry.h"

@interface BulletinTableViewCell()

@property (nonatomic) UILabel *bulletinLabel;
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *elapsedLabel;

@end

@implementation BulletinTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeSubViewLayouts];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadData: (BulletinModel *)model {
    self.model = model;
    NSMutableAttributedString *attriText = [[NSMutableAttributedString alloc]init];
    NSAttributedString *userAttriText = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", model.username] attributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}];
    [attriText appendAttributedString:userAttriText];
    NSAttributedString *actionText = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", model.actionStr]];
    [attriText appendAttributedString:actionText];
    NSAttributedString *targetAttriText = [[NSAttributedString alloc]initWithString:model.targetStr attributes:@{NSForegroundColorAttributeName: [UIColor DwinkRed]}];
    [attriText appendAttributedString:targetAttriText];
    self.bulletinLabel.attributedText = attriText;
    self.usernameLabel.text = model.username;
    self.elapsedLabel.text = model.elapsedStr;
}

- (void)triggererClicked:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            sender.view.backgroundColor = [UIColor selectionGrey];
            break;
        default:
            sender.view.backgroundColor = [UIColor clearColor];
            [self.delegate didClickTriggererAction:self.model];
            break;
    }
}

#pragma mark - Private methods

- (void)initializeSubViewLayouts {
    self.bulletinLabel = [[UILabel alloc]init];
    self.bulletinLabel.numberOfLines = 0;
    [self.contentView addSubview:self.bulletinLabel];
    
    self.usernameLabel = [[UILabel alloc]init];
    self.usernameLabel.textColor = [UIColor DwinkRed];
    self.usernameLabel.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(triggererClicked:)];
    longPress.minimumPressDuration = 0.0;
    [self.usernameLabel addGestureRecognizer: longPress];
    [self.contentView insertSubview:self.usernameLabel aboveSubview:self.bulletinLabel];
    
    self.elapsedLabel = [[UILabel alloc]init];
    self.elapsedLabel.font = [self.elapsedLabel.font fontWithSize:15.0];
    self.elapsedLabel.textColor = [UIColor DwinkGrey];
    [self.contentView addSubview:self.elapsedLabel];
    
    self.bulletinLabel.numberOfLines = 0;
    [self.bulletinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        make.bottom.equalTo(self.elapsedLabel.mas_top).offset(-8.0);
    }];
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(8.0);
        make.top.equalTo(self.contentView.mas_top).offset(8.0);
    }];
    [self.elapsedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8.0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8.0);
    }];
}

@end
