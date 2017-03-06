//
//  BlockedTableViewController.m
//  Dwink
//
//  Created by Steven Jia on 9/15/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "BlockedTableViewController.h"
#import "CustomIndicator.h"
#import "UserInfo.h"
#import "BlockedTableViewCell.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "DesignableUIKit.h"
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BlockedTableViewController ()<blockUserProtocol>

@property (nonatomic) CustomIndicator *indicator;
@property (nonatomic) NSArray<UserInfo *> *userArray;

@property (nonatomic) SocialAPI *socialAPI;

@end

@implementation BlockedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicator = [CustomIndicator newInstanceForView:self.tableView];
    
    self.socialAPI = [[SocialAPI alloc]init];
    [self.indicator showLoadingIndicator];
    [self getBlockUserList];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    __weak typeof (self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.socialAPI resetBlockedUserURLStr];
        [weakSelf getBlockUserList];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlockedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCell" forIndexPath:indexPath];
    [cell loadData:self.userArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73.0;
}

- (void)getBlockUserList {
    [self.socialAPI getBlockUserListWithSuccessHandler:^(NSArray<UserInfo *> *userInfoArray) {
        self.userArray = userInfoArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Complete"];
            [self.tableView reloadData];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hideIndicatorWithSuccessResponse:YES text:errorString];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
        });
    }];
}

- (void)didClickUnblockUserButton:(CustomButton *)sender userInfo:(UserInfo *)userInfo {
    
    [self.indicator showLoadingIndicator];
    
    if ([sender.currentTitle isEqualToString:@"Unblock"]) {
        [SocialAPI unBlockUserWithId:userInfo.idStr successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
                [sender setTitle:@"Block" forState:UIControlStateNormal];
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hideIndicatorWithSuccessResponse:NO text:errorString];
            });
        }];
    } else {
        [SocialAPI blockUserWithId:userInfo.idStr successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
                [sender setTitle:@"Unblock" forState:UIControlStateNormal];
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hideIndicatorWithSuccessResponse:NO text:errorString];
            });
        }];
    }
}

@end
