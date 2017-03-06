//
//  SocialTableViewConfigure.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/23/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "SocialTableViewConfigure.h"
#import "UserInfo.h"
#import "HomeTableViewNoImageCell.h"
#import "HomeTableViewOneImageCell.h"
#import "HomeTableViewOneLineImagesCell.h"
#import "HomeTableViewTwoLinesImagesCell.h"
#import "DetailImageViewController.h"
#import "DetailImageNavController.h"

@implementation SocialTableViewConfigure

static NSString *noImageCell = @"noImageCell";
static NSString *oneImageCell = @"oneImageCell";
static NSString *oneLineImagesCell = @"oneLineImagesCell";
static NSString *twoLinesImagesCell = @"twoLinesImagesCell";

+ (void)registerAllKindsOfPostTableViewCell: (UITableView *)tableView {
    [tableView registerClass:[HomeTableViewNoImageCell class] forCellReuseIdentifier:noImageCell];
    [tableView registerClass:[HomeTableViewOneImageCell class] forCellReuseIdentifier:oneImageCell];
    [tableView registerClass:[HomeTableViewOneLineImagesCell class] forCellReuseIdentifier:oneLineImagesCell];
    [tableView registerClass:[HomeTableViewTwoLinesImagesCell class] forCellReuseIdentifier:twoLinesImagesCell];
}

+ (__kindof UITableViewCell *)reuseDifferentTableViewCell: (UserInfo *)userInfo tableView: (UITableView *)tableView delegate: (id<CellDelegate>)delegate {
    return [self createDiffPostCells:userInfo tableView:tableView delegate:delegate hideUI:NO];
}

+ (__kindof UITableViewCell *)reuseDifferentTableViewCellForUserInfoPage: (UserInfo *)userInfo tableView: (UITableView *)tableView delegate: (id<CellDelegate>)delegate {
    return [self createDiffPostCells:userInfo tableView:tableView delegate:delegate hideUI:YES];
}

#pragma mark - Private methods

+ (__kindof UITableViewCell *)createDiffPostCells: (UserInfo *)userInfo tableView: (UITableView *)tableView delegate: (id<CellDelegate>)delegate hideUI: (BOOL)hide {
    NSUInteger imageArrayCount = userInfo.post.imageURLStrArray.count;
    __kindof HomeTableViewNoImageCell *cell;
    switch (imageArrayCount) {
        case 0:
            cell = (HomeTableViewNoImageCell *)[tableView dequeueReusableCellWithIdentifier:noImageCell];
            break;
        case 1:
            cell = (HomeTableViewOneImageCell *)[tableView dequeueReusableCellWithIdentifier:oneImageCell];
            break;
        case 2:
        case 3:
            cell = (HomeTableViewOneLineImagesCell *)[tableView dequeueReusableCellWithIdentifier:oneLineImagesCell];
            break;
        default:
            cell = (HomeTableViewTwoLinesImagesCell *)[tableView dequeueReusableCellWithIdentifier:twoLinesImagesCell];
            break;
    }
    cell.viewModel.delegate = delegate;
    [cell loadCellDataWithInfo:userInfo];
    if (hide) {
        [cell hidePublicInforUI];
    }
    return cell;
}

@end
