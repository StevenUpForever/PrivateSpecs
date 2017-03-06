//
//  CommentTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"

@protocol CommentCellDelegate <NSObject>

@optional
- (void)commentCellAvatarLabelClicked: (UserInfo *)userInfo;
- (void)didOccurDeleteCommentEvent: (CommentModel *)commentModel;

@end

@class CommentModel;
@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) id<CommentCellDelegate> delegate;

@property (nonatomic, readonly) CommentModel *model;

@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;

- (void)loadData: (CommentModel *)model;

@end
