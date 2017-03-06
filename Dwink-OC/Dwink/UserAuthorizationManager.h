//
//  UserAuthorizationManager.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/8/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAuthorizationManager : NSObject

/**
 *  Save user accessToken and user id into NSUserDefault
 *
 *  @param accessToken accessToken of user
 *  @param userId      user id of user
 */

+ (void)saveToken: (NSString *)accessToken userId: (NSString *)userId;

/**
 *  Login transition
 */

+ (void)loginTransition;

/**
 *  Login action with save user info and do login transition
 *
 *  @param token  accessToken of user
 *  @param userId user id of user
 */

+ (void)loginWithAccessToken: (NSString *)token userId: (NSString *)userId;

/**
 *  Logout Action with clean accessToken and userId also transition to LoginViewController
 */

+ (void)logOut;

/**
 *  Replace accessToken saved in local
 *
 *  @param token new accessToken
 */

+ (void)replaceAccessToken: (NSString *)token;

@end
