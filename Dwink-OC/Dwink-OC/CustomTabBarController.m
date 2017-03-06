//
//  CustomViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CustomTabBarController.h"
#import "HomeTableViewController.h"
#import "BulletinTableViewController.h"
#import "LoginViewController.h"
#import "CreatePostViewController.h"
#import "UIKitCategories.h"
#import "Masonry.h"

@interface CustomTabBarController ()

@property (nonatomic) UIButton *customCenterButton;

@property (nonatomic, assign) CGRect statusBarFrame;
@property (nonatomic, assign) CGPoint originalButtonCenter;

@end

@implementation CustomTabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        
        HomeTableViewController *HomeVC = [[HomeTableViewController alloc]init];
        UINavigationController *homeNavController = [[UINavigationController alloc]initWithRootViewController:HomeVC];
        homeNavController.tabBarItem.image = [UIImage imageNamed:@"homeIcon"];
        homeNavController.title = @"Home";
        
        BulletinTableViewController *bulletinVC = [[BulletinTableViewController alloc]init];
        UINavigationController *bulletinNavController = [[UINavigationController alloc]initWithRootViewController:bulletinVC];
        bulletinNavController.tabBarItem.image = [UIImage imageNamed:@"bulletinIcon"];
        bulletinNavController.title = @"Bulletin";
        
        UIViewController *blankVC = [[UIViewController alloc]init];
        blankVC.tabBarItem.enabled = NO;
        
        UINavigationController *friendsNav = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"friendsNav"];
        friendsNav.tabBarItem.image = [UIImage imageNamed:@"search"];
        friendsNav.tabBarItem.title = @"Friends";
        
        UIStoryboard *customStoryBoard = [UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil];
        UINavigationController *moreNacController = [customStoryBoard instantiateViewControllerWithIdentifier:@"moreNavController"];
        moreNacController.tabBarItem.image = [UIImage imageNamed:@"More40"];
        moreNacController.title = @"More";
        
        self.viewControllers = @[homeNavController, bulletinNavController, blankVC, friendsNav, moreNacController];
        
        _customCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"penIcon45"];
        
        self.customCenterButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width + 15, buttonImage.size.height + 15);
        [self.customCenterButton setImage:buttonImage forState:UIControlStateNormal];
        self.customCenterButton.backgroundColor = [UIColor DwinkRed];
        self.customCenterButton.layer.cornerRadius = 5.0;
        
        //Set central button center always be tabBar center
        
        [self.customCenterButton addTarget:self action:@selector(showAddTweetViewController) forControlEvents:UIControlEventTouchUpInside];
        CGFloat heightDifference = buttonImage.size.height + 15 - self.tabBar.frame.size.height;
        if (heightDifference < 0) self.customCenterButton.center = self.tabBar.center;
        else {
            CGPoint center = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            self.customCenterButton.center = center;
            _originalButtonCenter = center;
        }
        [self.view addSubview:self.customCenterButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

#pragma mark - IBActions



- (void)showAddTweetViewController {
    CreatePostViewController *createPostVC = [[CreatePostViewController alloc]init];
    UINavigationController *createPostNav = [[UINavigationController alloc]initWithRootViewController:createPostVC];
    [self presentViewController:createPostNav animated:YES completion:nil];
}

#pragma mark - Custom selectors

//Adjust central button center when status bar frame changed, like google map background model

- (void)statusBarWillChange: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *aValue = userInfo[UIApplicationStatusBarFrameUserInfoKey];
    CGFloat statusBarHeightDifference = aValue.CGRectValue.size.height - self.statusBarFrame.size.height;
    CGPoint buttonCenter = self.originalButtonCenter;
    buttonCenter.y -= statusBarHeightDifference;
    self.customCenterButton.center = buttonCenter;
}

@end
