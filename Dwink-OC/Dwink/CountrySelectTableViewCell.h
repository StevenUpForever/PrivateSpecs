//
//  CountrySelectTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 12/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class countryModel;
@interface CountrySelectTableViewCell : UITableViewCell

@property(nonatomic) countryModel *model;
- (void)loadData: (countryModel *)model;

@end

@interface countryModel : NSObject

@property(nonatomic, copy) NSString *countryName;
@property(nonatomic, copy) NSString *phoneCode;
@property(nonatomic, copy) NSString *countryCode;

- (instancetype)initWithName: (NSString *)countryName phoneCode: (NSString *)phoneCode countryCode: (NSString *)countryCode;

@end
