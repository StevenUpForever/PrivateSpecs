//
//  FollowButton.m
//  Dwink
//
//  Created by Steven Jia on 9/6/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "FollowButton.h"
#import "Masonry.h"

@interface FollowButton()

@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation FollowButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        self.indicator.hidesWhenStopped = YES;
        [self addSubview:self.indicator];
        [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
        _showIndicator = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        [self addSubview:self.indicator];
        [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
        _showIndicator = YES;
    }
    return self;
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    if (showIndicator) {
        [self.indicator startAnimating];
        self.enabled = NO;
    } else {
        [self.indicator stopAnimating];
        self.enabled = YES;
    }
}

@end
