//
//  CountrySelectTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 12/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CountrySelectTableViewCell.h"

@interface CountrySelectTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *countryName;
@property (weak, nonatomic) IBOutlet UILabel *phoneCode;

@end

@implementation CountrySelectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadData:(countryModel *)model {
    self.countryName.text = model.countryName;
    self.phoneCode.text = model.phoneCode;
    self.model = model;
}

@end

@implementation countryModel

- (instancetype)initWithName: (NSString *)countryName phoneCode: (NSString *)phoneCode countryCode: (NSString *)countryCode
{
    self = [super init];
    if (self) {
        _countryName = countryName;
        _phoneCode = phoneCode;
        _countryCode = countryCode;
    }
    return self;
}

@end
