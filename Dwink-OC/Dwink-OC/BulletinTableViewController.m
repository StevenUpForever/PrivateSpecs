//
//  BulletionTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "BulletinTableViewController.h"
#import "BulletinTableViewCell.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "UserInfoTableViewController.h"
#import "PendingRequestsTableViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface BulletinTableViewController ()<BulletinCellDelegate>

@property (nonatomic, copy) NSArray<BulletinModel *> *bulletinArray;
@property (nonatomic) SocialAPI *socialAPI;

@property (nonatomic) MBProgressHUD *indicator;

@end

static NSString *const cellIdentifier = @"cellIdentifier";

@implementation BulletinTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.socialAPI = [[SocialAPI alloc]init];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.tableView];
    self.indicator.labelText = @"Loading...";
    [self.tableView addSubview:self.indicator];
    
    self.navigationItem.title = @"Bulletin";
    self.bulletinArray = [[NSArray alloc]init];
    [self.tableView registerClass:[BulletinTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getBulletinActionWithNewResponse:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getBulletinActionWithNewResponse:NO];
    }];
    [self getBulletinActionWithNewResponse:YES];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    UserInfoNotification *userNotification = [UserInfoNotification notificationCenter];
    if (self.navigationController.tabBarItem.badgeValue) {
        [self getBulletinActionWithNewResponse:YES];
        [userNotification clearUnreadNotificationCountAndSet:self.navigationController.tabBarItem];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bulletinArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BulletinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell loadData:self.bulletinArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 24.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BulletinTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.model.type isEqualToString:@"UserRequestedToFollow"]) {
        PendingRequestsTableViewController *pending = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"pendingRequest"];
        [self.navigationController pushViewController:pending animated:YES];
    } else {
        [self transtionToUserInfoWithId:cell.model.actionId];
    }
}

#pragma mark - Private methods

- (void)getBulletinActionWithNewResponse: (BOOL)newResponse {
    
    if (newResponse) {
        [self.tableView.mj_header beginRefreshing];
        [self.socialAPI resetNotificationURLString];
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    [self.socialAPI getNotificationsWithSuccessHandler:^(NSArray<BulletinModel *> *bulletinArray) {
        if (newResponse) {
            self.bulletinArray = bulletinArray;
        } else {
            self.bulletinArray = [self.bulletinArray arrayByAddingObjectsFromArray:bulletinArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [self.tableView reloadData];
            
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            if ((self.socialAPI).noMoreNotifications) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [[UserInfoNotification notificationCenter]finishRefreshUI:self];
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            if ((self.socialAPI).noMoreHomeFeeds) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [CustomAlertController showCancelAlertControllerWithTitle:@"Failed to get Bulletin" message:nil action:nil target:self];
        });
    }];
}

#pragma mark - Cell delegate

- (void)didClickTriggererAction:(BulletinModel *)model {
    [self transtionToUserInfoWithId:model.triggererId];
}

#pragma mark - Private methods

- (void)transtionToUserInfoWithId: (NSString *)idString {
    [self.indicator show: YES];
    [SocialAPI getIndicateUserWithIdStr:idString successHandler:^(UserInfo *userInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
            [userInfoVC setUp:userInfo type:userInfoVCTypeHomeFeed];
            [self.navigationController pushViewController:userInfoVC animated:YES];
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [CustomAlertController showCancelAlertControllerWithTitle:@"Fetch user profile failed" message:nil action:nil target:self];
        });
    }];
}

@end
