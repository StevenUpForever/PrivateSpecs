//
//  PendingRequestsTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 10/30/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "PendingRequestsTableViewController.h"
#import "PendingRequestsTableViewCell.h"
#import "SocialAPI.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "UserInfoTableViewController.h"
#import "UserInfo.h"
#import <MJRefresh/MJRefresh.h>

@interface PendingRequestsTableViewController ()

@property (nonatomic) NSMutableArray<UserInfo *> *requestsArray;
@property (nonatomic) SocialAPI *socialAPI;
@property (nonatomic) MBProgressHUD *indicator;

@end

@implementation PendingRequestsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 73.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.requestsArray = [[NSMutableArray alloc]init];
    self.socialAPI = [[SocialAPI alloc]init];
    self.indicator = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    self.indicator.labelText = @"Loading...";
    [self.navigationController.view addSubview:self.indicator];
    [self.indicator show:YES];
    [self getPendingRequestsOfResponse:YES];
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getPendingRequestsOfResponse:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getPendingRequestsOfResponse:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requestsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PendingRequestsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pendingRequestsCell"];
    [cell loadData:self.requestsArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
    [userInfoVC setUp:self.requestsArray[indexPath.row] type:userInfoVCTypeHomeFeed];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark - API call & Selectors
- (IBAction)acceptRequest:(UIButton *)sender {
    NSInteger row = [self rowOfRequestCell:sender];
    [SocialAPI acceptPendingRequest:self.requestsArray[row].idStr successHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.requestsArray removeObjectAtIndex:row];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]withRowAnimation:UITableViewRowAnimationRight];
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}
- (IBAction)ignoreRequest:(UIButton *)sender {
    NSInteger row = [self rowOfRequestCell:sender];
    [SocialAPI ignorePendingRequest:self.requestsArray[row].idStr successHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.requestsArray removeObjectAtIndex:row];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]withRowAnimation:UITableViewRowAnimationRight];
        });
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}

- (NSInteger)rowOfRequestCell: (UIButton *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    return MIN(indexPath.row, self.requestsArray.count - 1);
}

- (void)getPendingRequestsOfResponse: (BOOL)newResponse {
    if (newResponse) {
        [self.socialAPI resetPendingRequestsURLStr];
        [self.tableView.mj_footer resetNoMoreData];
    }
    [self.socialAPI getPendingRequestsWithSuccessHandler:^(NSArray<UserInfo *> *userInfoArray) {
        if (newResponse) {
            self.requestsArray = [[NSMutableArray alloc]initWithArray:userInfoArray];
        } else {
            [self.requestsArray addObjectsFromArray:userInfoArray];
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
            if ([self.socialAPI noMorePendingRequests]) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
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
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}

@end
