//
//  CommentModel.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/23/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CommentModel.h"
#import "UserInfo.h"

@interface CommentModel()

@end

@implementation CommentModel

- (void)loadData: (NSDictionary *)detailDict {
    [self parseCommentStr:detailDict[@"comment"]];
    _commentId = detailDict[@"id"];
    _elapsed = detailDict[@"elapsed"];
    NSDictionary *user = detailDict[@"user"];
    UserInfo *newUser = [[UserInfo alloc]init];
    [newUser loadResponseObj:user];
    _userInfo = newUser;
    NSDictionary *mentionsDict = detailDict[@"mentions"];
    if ([mentionsDict isKindOfClass:[NSDictionary class]]) {
        NSArray *mentionDataArray = mentionsDict[@"data"];
        if ([mentionDataArray isKindOfClass:[NSArray class]]) {
            if (mentionDataArray.count > 0) {
                NSDictionary *mentionDetailDict = mentionDataArray[0];
                if ([mentionDetailDict isKindOfClass:[NSDictionary class]]) {
                    UserInfo *mentionedUser = [[UserInfo alloc]init];
                    [mentionedUser loadResponseObj:mentionDetailDict];
                    _mentionedUser = mentionedUser;
                }
            }
        }
    }
}

- (BOOL)isSelf {
    return self.userInfo.isSelf;
}

- (NSString *)commentViewPlaceHolder {
    return [NSString stringWithFormat:@"@%@", self.userInfo.userName];
}

#pragma mark - Private method

- (void)parseCommentStr: (NSString *)str {
    if (str.length == 0) {
        return;
    }
    int index = 0;
    while (index < str.length && [str characterAtIndex:index] == ' ') {
        index++;
    }
    if ([str characterAtIndex:index] == '@') {
        while (index < str.length) {
            char c = [str characterAtIndex:index];
            if (c == ' ') {
                _mentionStr = [str substringToIndex:index];
                _commentStr = [str substringFromIndex:index];
                return;
            }
            index++;
        }
        if (index == str.length) {
            _mentionStr = str;
        }
    } else {
        _commentStr = str;
    }
}

@end
