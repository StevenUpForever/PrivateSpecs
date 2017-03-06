//
//  LoadingTableViewCell.m
//  Dwink
//
//  Created by Steven Jia on 9/1/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "LoadingTableViewCell.h"

@interface LoadingTableViewCell()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.indicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
