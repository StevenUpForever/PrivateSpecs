//
//  PublicVariables.h
//  Dwink
//
//  Created by Chengzhi Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicVariables : NSObject

typedef void(^blankHandler)();

extern NSString *kDwinkAccessToken;
extern NSString *kDwinkUserId;
extern NSString *kUsername;
extern NSString *kChannelId;
extern NSString *privateProfileKey;

@end
