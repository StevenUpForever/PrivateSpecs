//
//  DetailImageNavController.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailImageViewModel.h"

@interface DetailImageNavController : UINavigationController

@property (nonatomic, assign) detailImageMode mode;

- (instancetype)initWithRootController: (UIViewController *)rootVC mode: (detailImageMode)mode NS_DESIGNATED_INITIALIZER;

@end
