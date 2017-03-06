//
//  UserInformationViewModel.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/3/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"

typedef NS_ENUM(NSUInteger, userInfoVCType) {
    userInfoVCTypeHomeFeed,
    userInfoVCTypeMore
};

@class UserInfo;
@interface UserInformationViewModel : NSObject

@property (nonatomic) UserInfo *userInfo;
@property (nonatomic, assign) userInfoVCType type;

- (void)setUp: (UserInfo *)userInfo type: (userInfoVCType)type;

/**
 Number of rows in tableView dataSource method helper

 @param section section of current tableViewCell

 @return the number of rows
 */
- (NSInteger)numberOfRowsFromViewModel: (NSInteger)section;

/**
 Estimate tableViewCell height to call in estimateHeightForTableViewCell data source

 @param indexPath indexPath of current tableViewCell

 @return the tableViewCell height of CGFloat type
 */
- (CGFloat)estimateHeightforCellAtIndexPath: (NSIndexPath *)indexPath;

/**
 tableView offset by the poped up keyboard

 @param aNotification the keyboard notification

 @return the frame of the current keyboard
 */
- (CGRect)tableViewOffsetNeeded: (NSNotification *)aNotification;

- (NSInteger)lastRowOfTableView: (NSInteger)lastRowInSectionZero;

/**
 Create comment string by components

 @param commentStr the commentString need to parse

 @return the complete comment string
 */
- (NSString *)createCompleteCommentString: (NSString *)commentStr;

@property (nonatomic) CommentModel *currentCommentModel;

@property (nonatomic, assign) BOOL needToLoadRefreshCell;
@property (nonatomic, assign) BOOL commentsHadLoaded;
@property (nonatomic, assign) BOOL shouldScrollTableView;

@property (nonatomic, assign) BOOL tempCommentIsInvalid;

@property (nonatomic, copy) NSString *tempCommentString;

- (CommentModel *)currentComment: (NSIndexPath *)indexPath;

- (void)removeDataFromCommentArray: (CommentModel *)model completionHandler: (blankHandler)completionHandler;

- (void)getInsertRowAndAddObjectForCommentDataSource: (CommentModel *)model completionHandler: (void(^)(NSInteger insertRow, BOOL shouldLoadMoreComments))completionHandler;

- (void)processCommentDataDependsOnResponse: (BOOL)newResponse commentArray: (NSArray<CommentModel *> *)commentArray;

@end
