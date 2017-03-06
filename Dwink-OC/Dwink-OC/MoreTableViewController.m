//
//  MoreTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "MoreTableViewController.h"
#import "LoginViewController.h"
#import "findEmailViewController.h"
#import "UserInfoTableViewController.h"
#import "UserInfo.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "UserAuthorizationManager.h"
#import "UIKitCategories.h"
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MoreTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UITableViewCell *userInfoCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *privateProfileCell;
@property (weak, nonatomic) IBOutlet UISwitch *privateProfileSwitch;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privateLabelLeft;

@end

@implementation MoreTableViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"More";
    self.indicator.hidesWhenStopped = YES;
    self.userInfoCell.userInteractionEnabled = NO;
    [self loadUserInfo];
    self.privateProfileSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:privateProfileKey];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadUserInfo];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUserInfo)
                                                 name:kBeginRefreshUI
                                               object:nil];
    
    if ([[UserInfoNotification notificationCenter] needRefreshUI:self]) {
        [self loadUserInfo];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBeginRefreshUI
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure to logout?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UserAuthorizationManager logOut];
            });
        }];
        [alertController addAction:cancel];
        [alertController addAction:confirm];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

#pragma mark - Custom Selectors

- (IBAction)privateProfileSet:(UISwitch *)sender {
    [SocialAPI updateUserProfile:nil bio:nil username:nil email:nil private:sender.on unreadNotifications:[UserInfo sharedInstance].unreadNotifyCount successHandler:^{
        
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomAlertController showCancelAlertControllerWithTitle:@"Can not change private profile state, please try again." message:nil action:nil target:self];
            sender.on = !sender.on;
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUserInfo"]) {
        UserInfoTableViewController *userInfoVC = segue.destinationViewController;
        [userInfoVC setUp:[UserInfo sharedInstance] type:userInfoVCTypeMore];
    }
}

#pragma mark - Private method

- (void)loadUserInfo {
    [self.indicator startAnimating];
    
    [SocialAPI getCurrentUserWithSuccessBlock:^(UserInfo *sharedUserInfo) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sharedUserInfo.profileImageUrlStr.length != 0) {
                NSURL *avatarURL = [NSURL URLWithString:sharedUserInfo.profileImageUrlStr];
                [self.userAvatar sd_setImageWithURL:avatarURL placeholderImage:[UIImage defaultCharacterImage:sharedUserInfo.fullName]];
            }
            self.nameLabel.text = sharedUserInfo.fullName;
            self.usernameLabel.text = sharedUserInfo.userName;
            [[NSUserDefaults standardUserDefaults] setBool:sharedUserInfo.privateProfile forKey:privateProfileKey];
            self.privateProfileSwitch.on = sharedUserInfo.privateProfile;
            
            [self.indicator stopAnimating];
            self.userInfoCell.userInteractionEnabled = YES;
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
        });
        
        [[UserInfoNotification notificationCenter] finishRefreshUI:self];
        
    } failureHandler:^(NSString *errorString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
        });
    }];
}

@end
