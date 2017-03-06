//
//  UploadingHintView.m
//  Dwink
//
//  Created by Chengzhi Jia on 9/17/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UploadingHintView.h"
#import "Masonry.h"

@interface UploadingHintView()

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation UploadingHintView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    _textLabel = [[UILabel alloc]init];
    [self addSubview:self.textLabel];
    self.textLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Uploading Post..." attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:22.0]}];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.indicator];
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textLabel);
        make.right.equalTo(self.textLabel.mas_left).with.offset(-5.0);
    }];
    [self.indicator startAnimating];
}

@end
