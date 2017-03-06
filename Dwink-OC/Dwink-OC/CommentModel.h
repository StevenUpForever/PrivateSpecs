//
//  CommentModel.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/23/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;
@interface CommentModel : NSObject

@property (nonatomic, readonly, copy) NSString *mentionStr;
@property (nonatomic, readonly, copy) NSString *commentStr;
@property (nonatomic, readonly, copy) NSString *elapsed;
@property (nonatomic, readonly, copy) NSString *commentId;
@property (nonatomic) UserInfo *mentionedUser;
@property (nonatomic) UserInfo *userInfo;

@property (nonatomic, assign) BOOL isSelf;

@property (nonatomic, copy) NSString *commentViewPlaceHolder;

- (void)loadData: (NSDictionary *)detailDict;

@end
