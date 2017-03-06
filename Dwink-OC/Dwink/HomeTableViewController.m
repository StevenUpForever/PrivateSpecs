//
//  HomeTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "HomeTableViewController.h"
#import "SocialTableViewConfigure.h"
#import "UserInfoTableViewController.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "UserInfo.h"
#import "DetailImageNavController.h"
#import "CustomIndicator.h"
#import "UploadingHintView.h"
#import "DetailImageViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface HomeTableViewController ()<CellDelegate>

@property (nonatomic) CustomIndicator *indicator;

@property (nonatomic) SocialAPI *socialAPI;
@property (nonatomic, copy) NSArray<UserInfo *> *followingArray;

@property (nonatomic) UploadingHintView *hintView;

@end

@implementation HomeTableViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.followingArray = [[NSMutableArray alloc]init];
    self.socialAPI = [[SocialAPI alloc]init];
    
    self.hintView = [[UploadingHintView alloc]initWithFrame:self.navigationItem.titleView.bounds];
    
    //remove black line when there's no data in this UITableView
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Initial tableView and register tableViewCell
    [SocialTableViewConfigure registerAllKindsOfPostTableViewCell:self.tableView];
    
    self.navigationItem.title = @"Home";
    
    //Initialize indicator
    self.indicator = [CustomIndicator newInstanceForView:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getHomeFeedListWithNewResponse:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getHomeFeedListWithNewResponse:NO];
    }];
    
    [self getHomeFeedListWithNewResponse:YES];
    
    [SocialAPI getCurrentUserWithSuccessBlock:^(UserInfo *sharedUserInfo) {
    } failureHandler:^(NSString *errorString) {
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getRefreshUINotification) name:kBeginRefreshUI object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedTitleChange) name:kFailedRefreshUI object:nil];
    
    if ([[UserInfoNotification notificationCenter] needRefreshUI:self]) {
        [self getRefreshUINotification];
    }
    if ([UserInfoNotification notificationCenter].needBeginUploadingHint) {
        [self beginTitleChange];
    } else {
        [self failedTitleChange];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kBeginRefreshUI object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kFailedRefreshUI object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followingArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *info = self.followingArray[indexPath.row];
    return [SocialTableViewConfigure reuseDifferentTableViewCell:info tableView:tableView delegate:self];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
    [userInfoVC setUp:self.followingArray[indexPath.row] type:userInfoVCTypeHomeFeed];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserInfo *info = self.followingArray[indexPath.row];
    NSUInteger arrayCount = info.post.imageURLStrArray.count;
    
    if (arrayCount == 0) {
        return 135.0;
    } else if (arrayCount == 1) {
        return 218.0;
    }else if (arrayCount <= 3) {
        return 262.0;
    } else {
        return 395.0;
    }
}

#pragma mark - Selectors

- (void)getRefreshUINotification {
    [self getHomeFeedListWithNewResponse:YES];
}

- (void)beginTitleChange {
    self.navigationItem.titleView = self.hintView;
}

- (void)failedTitleChange {
    self.navigationItem.titleView = nil;
}

- (void)getHomeFeedListWithNewResponse: (BOOL)newResponse {
    
    if (newResponse) {
        [self.tableView.mj_header beginRefreshing];
        [self.socialAPI resetHomeFeedString];
        [self.tableView.mj_footer resetNoMoreData];
        [UserInfoNotification notificationCenter].needBeginUploadingHint = NO;
    }
    
    [self.socialAPI getHomeFeedWithSuccessHandler:^(NSArray<UserInfo *> *userInfoArray) {
        
        if (newResponse) {
            self.followingArray = userInfoArray;
        } else {
            self.followingArray = [self.followingArray arrayByAddingObjectsFromArray:userInfoArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self failedTitleChange];
            [self.indicator hide:YES];
            [self.tableView reloadData];
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            if ((self.socialAPI).noMoreHomeFeeds) {
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
            [self failedTitleChange];
            if ([errorString isEqualToString:kNeedLogOutKey]) {
                [CustomAlertController forceLogoutAlertControllerForTarget:self];
            } else {
                [CustomAlertController showCancelAlertControllerWithTitle:@"Error" message:errorString action:nil target:self];
            }
        });
    }];
    
}

#pragma mark - Cell delegate

- (void)didClickImageViewOnCell:(NSArray *)urlStrArray currentIndex:(NSUInteger)index {
    DetailImageViewController *detailVC = [[DetailImageViewController alloc]initWithURLArray:urlStrArray andCurrentIndex:index];
    DetailImageNavController *navCon = [[DetailImageNavController alloc]initWithRootController:detailVC mode:detailImageModeOthers];
     [self.view.window.rootViewController presentViewController:navCon animated:YES completion:nil];
}

- (void)didClickActionMenu:(UserInfo *)userInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        void(^actionHandler)(UIAlertAction *action) = ^(UIAlertAction *action){
            [self.indicator showLoadingIndicator];
            [SocialAPI reportUserWithReason:action.title idStr:userInfo.idStr successHandler:^{
                [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
            } failureHandler:^(NSString *errorString) {
                [self.indicator hideIndicatorWithSuccessResponse:false text:errorString];
            }];
        };
        
        UIAlertController *spamAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [spamAlert addAction:[UIAlertAction actionWithTitle:@"It's Spam" style:UIAlertActionStyleDestructive handler:actionHandler]];
        [spamAlert addAction:[UIAlertAction actionWithTitle:@"It's Inappropriate" style:UIAlertActionStyleDestructive handler:actionHandler]];
        [spamAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self.view.window.rootViewController presentViewController:spamAlert animated:YES completion:nil];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle: userInfo.isBlocked ? @"Unblock" : @"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.indicator showLoadingIndicator];
        
        if (userInfo.isBlocked) {
            [SocialAPI unBlockUserWithId:userInfo.idStr successHandler:^{
                [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
            } failureHandler:^(NSString *errorString) {
                [self.indicator hideIndicatorWithSuccessResponse:false text:errorString];
            }];
        } else {
            [SocialAPI blockUserWithId:userInfo.idStr successHandler:^{
                [self.indicator hideIndicatorWithSuccessResponse:YES text:@"Success"];
            } failureHandler:^(NSString *errorString) {
                [self.indicator hideIndicatorWithSuccessResponse:false text:errorString];
            }];
        }
    }]];
    [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)didClickCommentButton:(UserInfo *)userInfo {
    UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
    [userInfoVC setUp:userInfo type:userInfoVCTypeHomeFeed];
    userInfoVC.viewModel.shouldScrollTableView = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

@end
