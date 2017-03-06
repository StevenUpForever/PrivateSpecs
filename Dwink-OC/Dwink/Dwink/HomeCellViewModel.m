//
//  HomeCellViewModel.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "HomeCellViewModel.h"
#import "UserInfo.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeCellViewModel()

@property (nonatomic) UserInfo *userInfo;

@property (nonatomic, copy) NSArray *imageURLStrArray;

@end

@implementation HomeCellViewModel

- (void)loadUserInfo: (UserInfo *)userInfo {
    
    self.userInfo = userInfo;
    
    self.profilePlaceHolder = [UIImage defaultCharacterImage:userInfo.fullName];
    
    self.profileURL = [NSURL URLWithString:userInfo.profileImageUrlStr];
    self.username = userInfo.userName;
    self.fullname = userInfo.fullName;
    self.text = userInfo.post.postText;
    self.likesCountString = [self properLikesStr];
    self.commentsCountString = [NSString stringWithFormat:@"%li", (unsigned long)userInfo.post.post_commentsCount];
    self.elapsed = (userInfo.post.createTime).fetchElapsedString;;
    self.imageURLStrArray = userInfo.post.imageURLStrArray;
    self.likeImage = userInfo.post.isLiked ? [UIImage imageNamed:@"likedFilled"] : [UIImage imageNamed:@"like"];
}

- (void)loadImageCollection: (NSArray<UIImageView *> *)imageViewCollection {
    
    switch (self.imageURLStrArray.count) {
        case 0:
            break;
        case 4:
            for (int index = 0; index < self.imageURLStrArray.count; index++) {
                if (index >= 2) {
                    [self configureCellContent:imageViewCollection[index + 1] urlStrArray:self.imageURLStrArray currentIndex:index];
                } else {
                    [self configureCellContent:imageViewCollection[index] urlStrArray:self.imageURLStrArray currentIndex:index];
                }
            }
            [self deleteImageForImageView:imageViewCollection[2]];
            [self deleteImageForImageView:imageViewCollection[5]];
            break;
            
        default:
            for (int index = 0; index < self.imageURLStrArray.count; index++) {
                [self configureCellContent:imageViewCollection[index] urlStrArray:self.imageURLStrArray currentIndex:index];
            }
            for (NSInteger index2 = imageViewCollection.count - 1; index2 >= self.imageURLStrArray.count; index2--) {
                [self deleteImageForImageView:imageViewCollection[index2]];
            }
            break;
    }
}

- (void)addGestureForOneImageView: (UIImageView *)imageView {
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)]];
}

- (void)configureCellContentForOneImage: (UIImageView *)imageView urlStr: (NSString *)urlStr maxWidth: (CGFloat)maxWidth completionHandler: (void(^)(UIImage *resizedImage))completionHandler {
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageFromColor:[UIColor lightGrayColor]] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            UIImage *newImage = [self properImageForImage:image comparedImageView:imageView maxWidth: maxWidth];
            imageView.image = newImage;
            if (completionHandler) {
                completionHandler(newImage);
            }
        }
//        UIImage *newImage = image ? [self properImageForImage:image comparedImageView:imageView maxWidth: maxWidth] : [self properImageForImage:[UIImage imageNamed:@"errorpage"] comparedImageView:imageView maxWidth: maxWidth];
//        imageView.image = newImage;
//        if (completionHandler) {
//            completionHandler(newImage);
//        }
    }];
}

- (void)addLikesGesture: (UILabel *)likesLabel {
    likesLabel.userInteractionEnabled = YES;
    likesLabel.textColor = [UIColor DwinkRed];
    [likesLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesLabelClicked:)]];
}

- (void)addGestureForActionMenu: (UIImageView *)actionMenu {
    [actionMenu addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionMenuClicked:)]];
}

- (void)commentButtonAction: (UIButton *)commentButton {
    [commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)likePostWithUIUpdate: (void(^)(BOOL liked))callback {
    
    if (self.userInfo.post.isLiked) {
        [SocialAPI unLikePost:self.userInfo.idStr successHandler:^{
            [self.userInfo.post changeLikeStatus:NO];
            self.likesCountString = [self properLikesStr];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(NO);
                }
            });
        } failureHandler:^(NSString *errorString) {
            NSLog(@"%@", errorString);
        }];
    } else {
        [SocialAPI likePost:self.userInfo.idStr successHandler:^{
//            if (!self.userInfo.isSelf) {
//                [UserInfoNotification pushNotificationToUser:self.userInfo.idStr notifyType:notificationTypePostLiked];
//            }
            [self.userInfo.post changeLikeStatus:YES];
            self.likesCountString = [self properLikesStr];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(YES);
                }
            });
        } failureHandler:^(NSString *errorString) {
            NSLog(@"%@", errorString);
        }];
    }
}

#pragma mark - Custom delegate

- (void)imageViewClicked: (UITapGestureRecognizer *)gesture {
    [self.delegate didClickImageViewOnCell:self.imageURLStrArray currentIndex:gesture.view.tag];
}

- (void)actionMenuClicked: (UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(didClickActionMenu:)]) {
        [self.delegate didClickActionMenu:self.userInfo];
    }
}

- (void)likesLabelClicked: (UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(didClickLikesLabel:)]) {
        [self.delegate didClickLikesLabel:self.userInfo];
    }
}

- (void)commentButtonClicked: (UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickCommentButton:)]) {
        [self.delegate didClickCommentButton:self.userInfo];
    }
}

#pragma mark - private methods

- (void)deleteImageForImageView: (UIImageView *)imageView {
    imageView.image = nil;
    imageView.userInteractionEnabled = NO;
}

- (void)configureCellContent: (UIImageView *)imageView urlStrArray: (NSArray *)urlStrArray currentIndex: (NSUInteger)index {
    [imageView asyncLoadImageWithCroppedImageOfURL:urlStrArray[index] placeHolderImage:[UIImage imageFromColor:[UIColor lightGrayColor]]];
    imageView.tag = index;
    imageView.userInteractionEnabled = YES;
}

- (UIImage *)properImageForImage: (UIImage *)image comparedImageView: (UIImageView *)imageView maxWidth: (CGFloat)maxWidth {
    CGFloat imageSizeWidth = image.size.width;
    CGFloat imageSizeHeight = image.size.height;
    CGFloat imageViewHeight = imageView.frame.size.height;
    CGFloat realWidth = imageSizeWidth / imageSizeHeight * imageViewHeight;
    UIImage *resizedImage;
    if (realWidth > maxWidth) {
        UIImage *tempImage = [image resizeImageToSize:CGSizeMake(realWidth, imageViewHeight)];
        resizedImage = [tempImage imageByCroppingImageToSize:CGSizeMake(maxWidth, imageViewHeight)];
    } else {
        resizedImage = [image resizeImageToSize:CGSizeMake(realWidth, imageViewHeight)];
    }
    return resizedImage;
}

- (NSString *)properLikesStr {
    return self.userInfo.post.likesCount > 1 ? [NSString stringWithFormat:@"%li likes", (unsigned long)self.userInfo.post.likesCount] : [NSString stringWithFormat:@"%li like", (unsigned long)self.userInfo.post.likesCount];
}

@end
