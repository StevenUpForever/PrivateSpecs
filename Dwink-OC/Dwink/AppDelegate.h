//
//  AppDelegate.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UINavigationController *loginNav;

@property (nonatomic) CustomTabBarController *tabBarController;

@property (strong, nonatomic) UIWindow *window;

@end

