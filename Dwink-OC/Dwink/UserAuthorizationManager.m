//
//  UserAuthorizationManager.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/8/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserAuthorizationManager.h"
#import "CustomTabBarController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "ImageManager.h"
#import "FoundationCategories.h"
#import <Parse/Parse.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation UserAuthorizationManager

+ (void)saveToken: (NSString *)accessToken userId: (NSString *)userId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:accessToken forKey:kDwinkAccessToken];
    [userDefault setObject:userId forKey:kDwinkUserId];
    [userDefault setObject:userId.setChannelIdStr forKey:kChannelId];
    
    // Store the deviceToken in the current installation and save it to Parse.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    currentInstallation.channels = @[userId.setChannelIdStr];
    [currentInstallation saveInBackground];
}

+ (void)loginTransition {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.tabBarController = [[CustomTabBarController alloc]init];
    [UIView transitionWithView:delegate.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        delegate.tabBarController.selectedIndex = 0;
        delegate.window.rootViewController = delegate.tabBarController;
    } completion:nil];
}

+ (void)loginWithAccessToken: (NSString *)token userId: (NSString *)userId {
    [self saveToken:token userId:userId];
    [self loginTransition];
}

+ (void)logOut {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:kDwinkAccessToken];
    [userDefault removeObjectForKey:kDwinkUserId];
    [userDefault removeObjectForKey:kUsername];
    [userDefault removeObjectForKey:kChannelId];
    
    [self logOutTransition];
}

+ (void)replaceAccessToken: (NSString *)token {
    [[NSUserDefaults standardUserDefaults]setObject:token forKey:kDwinkAccessToken];
}

#pragma mark - private methods

+ (void)logOutTransition {
    [ImageManager clearAllLogoutCacheData];
    FBSDKLoginManager *fbLoginManager = [[FBSDKLoginManager alloc]init];
    [fbLoginManager logOut];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.loginNav popToRootViewControllerAnimated:YES];
    [UIView transitionWithView:delegate.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        delegate.window.rootViewController = delegate.loginNav;
    } completion:nil];
}

@end
