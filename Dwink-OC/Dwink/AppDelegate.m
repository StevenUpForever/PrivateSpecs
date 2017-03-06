//
//  AppDelegate.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CoreDataProcessor.h"
#import "UIKitCategories.h"
#import "UserInfoNotification.h"
#import <AWSCore/AWSCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <DigitsKit/DigitsKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (nonatomic) NSDate *backgroundTime;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"XcZVSLwzTjEsxd4K4PdWmTpenzSgh0PS4kzUqFvI" clientKey:@"iN5zLSLsucBv6Rk40UlHHS0zYXGUWJnc592OVtDw"];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    //Extend launching screen for 1s
    
    [NSThread sleepForTimeInterval:1.0];
    
    //Must called before fetch FBSDKAccessToken
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Update or creat FBSDKProfile when accessToken
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:5e0507fe-eb54-42e4-a5f1-85306df6f751"];
 
//    #warning Need to config
//    
//#ifdef DEBUG
//    
//    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
//                                                                                                    identityPoolId:@"us-east-1:5e0507fe-eb54-42e4-a5f1-85306df6f751"];
//    
//    
//#else
//    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]initWithAccessKey:@"AKIAJIQM5QQC5RURHAHA" secretKey:@"xUtfB3XEC8Cl+/FhOW/9nYSefLyhwrr3mGpnEX"];
//#endif
    
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    configuration.timeoutIntervalForResource = 20.0;
    configuration.maxRetryCount = 3;
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    [Fabric with:@[[Crashlytics class], [Digits class]]];
    
    //Creat root viewController
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.loginNav = [[UIStoryboard storyboardWithName:@"LoginSignUp" bundle:nil]instantiateViewControllerWithIdentifier:@"loginNav"];
    self.tabBarController = [[CustomTabBarController alloc]init];
    self.tabBarController.selectedIndex = 0;
    
    if ([userDefaults objectForKey:kDwinkAccessToken]) {
        self.window.rootViewController = self.tabBarController;
    } else {
        self.window.rootViewController = self.loginNav;
    }
    
    [self.window makeKeyAndVisible];
    
    //Set navigationBar style
    
    [UINavigationBar appearance].barTintColor = [UIColor DwinkRed];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:22.0]};
    [UITabBar appearance].tintColor = [UIColor DwinkRed];
    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"backButton"];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -100) forBarMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundTime = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    application.applicationIconBadgeNumber = 0;
    UserInfoNotification *notification = [UserInfoNotification notificationCenter];
    if (self.backgroundTime) {
        NSTimeInterval time = [[NSDate date]timeIntervalSinceDate:self.backgroundTime];
        if (time > 300.0) {
            [notification beginNotifyRefreshUI];
        }
    }
    if (self.tabBarController.selectedIndex != 1) {
        [notification getUnreadNotificationCountAndSet:self.tabBarController.tabBar.items[1]];
    } else {
        self.tabBarController.tabBar.items[1].badgeValue = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    CoreDataProcessor *processor = [CoreDataProcessor sharedProcesser];
    [processor saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                    annotation:annotation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSString *channelId = [[NSUserDefaults standardUserDefaults] objectForKey:kChannelId];
    if (channelId) {
        currentInstallation.channels = @[channelId];
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (self.tabBarController.selectedIndex != 1) {
        UserInfoNotification *userNotifictaion = [UserInfoNotification notificationCenter];
        [userNotifictaion getUnreadNotificationCountAndSet:self.tabBarController.tabBar.items[1]];
    }
    [PFPush handlePush:userInfo];
}

@end
