//
//  UserInformationViewModel.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/3/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserInformationViewModel.h"
#import "UserInfo.h"
#import "SocialAPI.h"

@interface UserInformationViewModel()

@property (nonatomic, assign) BOOL finishLoadComment;
@property (nonatomic, assign) BOOL shouldScrollToComments;
@property (nonatomic) NSMutableArray<CommentModel *> *commentArray;

@end

@implementation UserInformationViewModel

#pragma mark = UserInfo helper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldScrollToComments = NO;
        _finishLoadComment = NO;
        self.commentArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)setUp: (UserInfo *)userInfo type: (userInfoVCType)type {
    self.userInfo = userInfo;
    self.type = type;
}

#pragma mark - tableView dataSource & delegate helper

- (NSInteger)numberOfRowsFromViewModel: (NSInteger)section {
    if (!self.userInfo.isSelf && !self.userInfo.isFollowing && self.userInfo.privateProfile) {
        return 1;
    } else {
        if (self.finishLoadComment) {
            return self.commentArray.count + 2;
        } else {
            return self.commentArray.count == 0 ? 3 : self.commentArray.count + 2;
        }
    }
}

- (CGFloat)estimateHeightforCellAtIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 330.0;
    } else if (indexPath.row == 1) {
        NSUInteger arrayCount = [UserInfo sharedInstance].post.imageURLStrArray.count;
        if (arrayCount == 0) {
            return 135.0;
        } else if (arrayCount <= 3) {
            return 262.0;
        } else {
            return 395.0;
        }
    } else {
        return 71.0;
    }
}

- (CGRect)tableViewOffsetNeeded: (NSNotification *)aNotification {
    NSDictionary *userInfo = aNotification.userInfo;
    NSValue *aValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    __block  CGFloat keyboardHeight = aValue.CGRectValue.size.height;
    if (keyboardHeight == 0.0) {
        return CGRectZero;
    }
    return aValue.CGRectValue;
}

#pragma mark - tableView Action

- (NSInteger)lastRowOfTableView: (NSInteger)lastRowInSectionZero {
    return MIN(self.commentArray.count + 1, lastRowInSectionZero);
}

#pragma mark - Comments part

- (BOOL)commentsHadLoaded {
    return self.commentArray.count > 0;
}

- (BOOL)needToLoadRefreshCell {
    return self.commentArray.count == 0 && !self.finishLoadComment;
}

- (CommentModel *)currentComment: (NSIndexPath *)indexPath {
    return self.commentArray[indexPath.row - 2];
}

- (BOOL)tempCommentIsInvalid {
    return self.tempCommentString == nil || self.tempCommentString.length == 0;
}

- (BOOL)shouldScrollTableView {
    return self.commentArray.count > 0 && self.shouldScrollToComments;
}

//Tricky part, when set should scrollTableView actually it's setting shouldScrollToComments, due to override getter of shouldScrollTableView
- (void)setShouldScrollTableView:(BOOL)shouldScrollTableView {
    _shouldScrollToComments = shouldScrollTableView;
}

- (NSString *)createCompleteCommentString: (NSString *)commentStr {
    if ([commentStr hasPrefix:@"@"]) {
        return commentStr;
    } else {
        return self.currentCommentModel ? [NSString stringWithFormat:@"%@ %@", self.currentCommentModel.commentViewPlaceHolder, commentStr] : commentStr;
    }
}

- (void)removeDataFromCommentArray: (CommentModel *)model completionHandler: (blankHandler)completionHandler {
    if ([self.commentArray containsObject:model]) {
        [self.commentArray removeObject:model];
        if (completionHandler) {
            completionHandler();
        }
    }
}

- (void)getInsertRowAndAddObjectForCommentDataSource: (CommentModel *)model completionHandler: (void(^)(NSInteger insertRow, BOOL shouldLoadMoreComments))completionHandler {
    [self.commentArray addObject:model];
    if (completionHandler) {
        completionHandler(self.commentArray.count + 1, self.shouldScrollToComments);
    }
}

- (void)processCommentDataDependsOnResponse: (BOOL)newResponse commentArray: (NSArray<CommentModel *> *)commentArray {
    if (newResponse) {
        self.commentArray = [[NSMutableArray alloc]initWithArray:commentArray];
    } else {
        [self.commentArray addObjectsFromArray:commentArray];
    }
    self.finishLoadComment = YES;
}

@end
