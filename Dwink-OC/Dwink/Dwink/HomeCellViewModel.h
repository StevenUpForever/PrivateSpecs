//
//  HomeCellViewModel.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKitCategories.h"
#import "FoundationCategories.h"


@class UserInfo;
@protocol CellDelegate <NSObject>

- (void)didClickImageViewOnCell: (NSArray *)urlStrArray currentIndex: (NSUInteger)index;

@optional
- (void)didClickActionMenu: (UserInfo *)userInfo;
- (void)didClickLikesLabel: (UserInfo *)userInfo;
- (void)didClickCommentButton: (UserInfo *)userInfo;

@end

@interface HomeCellViewModel : NSObject

@property (nonatomic, weak) id<CellDelegate> delegate;

@property (nonatomic) NSURL *profileURL;
@property (nonatomic) UIImage *profilePlaceHolder;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *fullname;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *likesCountString;
@property (nonatomic, copy) NSString *commentsCountString;
@property (nonatomic, copy) NSString *elapsed;
@property (nonatomic) UIImage *likeImage;

- (void)loadUserInfo: (UserInfo *)userInfo;

/**
 *  likePost method to pass only UI callback to view
 *
 *  @param callback callback to update UI when successfully like/unlike the post
 */

- (void)likePostWithUIUpdate: (void(^)(BOOL liked))callback;

/**
 *  Async load images into imageViewCollection from imageURLStringArray
 *
 *  @param imageViewCollection NSArray of UIImageView to load images into it
 */

- (void)loadImageCollection: (NSArray<UIImageView *> *)imageViewCollection;

/**
 Add Gesture for imageView when initialize tableViewCell

 @param imageView imageView to add gesture
 */
- (void)addGestureForOneImageView: (UIImageView *)imageView;


/**
 Configure one image post cell imageView

 @param imageView         the imageView to load image
 @param urlStr            url string of image need to load
 @param maxWidth          the max width which image size cannot over draw
 @param completionHandler callback when successfully resize image to use to update constraints
 */
- (void)configureCellContentForOneImage: (UIImageView *)imageView urlStr: (NSString *)urlStr maxWidth: (CGFloat)maxWidth completionHandler: (void(^)(UIImage *resizedImage))completionHandler;


/**
 Add tap gesture for action menu imageView

 @param actionMenu the action menu imageView to add gesture on
 */
- (void)addGestureForActionMenu: (UIImageView *)actionMenu;


/**
 Add tap gesture for like label

 @param likesLabel the like label to add gesture on
 */
- (void)addLikesGesture: (UILabel *)likesLabel;


/**
 Add Selector for commentButton automatically scroll to comment part in user info page

 @param commentButton the comment bubble button to perform action
 */
- (void)commentButtonAction: (UIButton *)commentButton;

@end
