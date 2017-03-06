//
//  BulletinTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletinModel.h"

@interface BulletinTableViewCell : UITableViewCell

@property (nonatomic) BulletinModel *model;

@property (weak, nonatomic) id<BulletinCellDelegate> delegate;

- (void)loadData: (BulletinModel *)model;

@end
