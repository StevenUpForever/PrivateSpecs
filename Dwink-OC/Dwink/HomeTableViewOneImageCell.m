//
//  HomeTableViewOneImageCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/10/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "HomeTableViewOneImageCell.h"

@interface HomeTableViewOneImageCell()

@property (nonatomic) UIImageView *postImageView;

@property (nonatomic) MASConstraint *postImageViewWidth;

//@property (nonatomic) NSLayoutConstraint *imageWidth;

@end

@implementation HomeTableViewOneImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 255.0, 160.0)];
        self.postImageView.contentMode = UIViewContentModeTopLeft;
        self.postImageView.clipsToBounds = YES;
        self.postImageView.layer.masksToBounds = YES;
        self.postImageView.backgroundColor = [UIColor lightGrayColor];
        self.postImageView.userInteractionEnabled = YES;
        [self.viewModel addGestureForOneImageView:self.postImageView];
        [self.postView addSubview:self.postImageView];
        self.postViewHeight.mas_equalTo(160.0);
        [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.postView.mas_top).offset(0.0);
            make.leading.equalTo(self.postView.mas_leading).offset(0.0);
            make.bottom.equalTo(self.postView.mas_bottom).offset(0.0);
            self.postImageViewWidth = make.width.mas_equalTo(255.0);
        }];
    }
    return self;
}

- (void)loadCellDataWithInfo:(UserInfo *)info {
    [super loadCellDataWithInfo:info];
    CGFloat width = self.contentView.bounds.size.width - 80;
    [self.viewModel configureCellContentForOneImage:self.postImageView urlStr:info.post.imageURLStrArray[0] maxWidth:width completionHandler:^(UIImage *resizedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.postImageViewWidth.mas_equalTo(resizedImage.size.width);
        });
    }];
}

@end
