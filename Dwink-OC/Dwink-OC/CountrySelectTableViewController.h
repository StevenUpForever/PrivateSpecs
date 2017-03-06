//
//  CountrySelectTableViewController.h
//  Dwink
//
//  Created by Chengzhi Jia on 12/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class countryModel;
@protocol countrySelectDelegate <NSObject>

- (void)didFinishedCountrySelected: (countryModel *)model;

@end

@interface CountrySelectTableViewController : UITableViewController

@property (nonatomic, weak) id<countrySelectDelegate> delegate;

@end
