//
//  SuperPostTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

@class UserInfo;
@class HomeCellViewModel;
@interface HomeTableViewNoImageCell : UITableViewCell

@property (nonatomic) HomeCellViewModel *viewModel;
@property (nonatomic) UIView *postView;
@property (nonatomic) MASConstraint *postViewHeight;

- (void)loadCellDataWithInfo: (UserInfo *)info;
- (void)hidePublicInforUI;

@end
