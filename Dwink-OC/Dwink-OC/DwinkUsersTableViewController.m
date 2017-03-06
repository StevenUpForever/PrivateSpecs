//
//  DwinkUsersTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "DwinkUsersTableViewController.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "DwinkUsersTableViewCell.h"
#import "UserInfo.h"
#import "UserInfoTableViewController.h"
#import "MentionTableViewCell.h"
#import <MJRefresh/MJRefresh.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface DwinkUsersTableViewController ()<UISearchBarDelegate, FBSDKAppInviteDialogDelegate>

@property (nonatomic) UserInfo *userInfo;
@property (nonatomic, assign) userListTableViewType type;
@property (nonatomic, copy) NSArray<UserInfo *> *usersArray;
@property (nonatomic, copy) NSArray<UserInfo *> *filtedArray;
@property (nonatomic) NSMutableArray *fbIdArray;

@property (nonatomic, assign) BOOL showSearchResults;
@property (nonatomic) SocialAPI *socialAPI;

@property (nonatomic) UISearchBar *searchBar;

@property (nonatomic) MBProgressHUD *indicator;

@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation DwinkUsersTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _type = userListTableViewTypeAllUsers;
    }
    return self;
}

- (void)setUpUserInfo: (UserInfo *)userInfo type: (userListTableViewType)type {
    self.userInfo = userInfo;
    self.type = type;
}

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicator = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    self.indicator.labelText = @"Loading...";
    [self.navigationController.view addSubview:self.indicator];
    
    if (self.userInfo) {
        self.socialAPI = [[SocialAPI alloc]initWithIdStr:self.userInfo.idStr isSelf:self.userInfo.isSelf];
    } else {
        self.socialAPI = [[SocialAPI alloc]init];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.usersArray = [[NSArray alloc]init];
    
    switch (self.type) {
        case userListTableViewTypeFollowings: {
            self.navigationItem.title = @"Followings";
            break;
        }
        case userListTableViewTypeFollowers: {
            self.navigationItem.title = @"Followers";
            break;
        }
        case userListTableViewTypeAllUsers: {
            [self initializeSearchBar];
            break;
        }
        case userListTableViewTypeLikes: {
            self.navigationItem.title = @"Likes";
            break;
        }
        case userListTableViewTypeMentions: {
            self.navigationItem.title = @"Mentions";
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMentionsList)];
            [self initializeSearchBar];
            break;
        }
        case userListTableViewTypeFBFriends: {
            self.navigationItem.title = @"Friends from Facebook";
            self.fbIdArray = [[NSMutableArray alloc]init];
            [self.fbIdArray addObject:[self.userInfo.fbId copy]];
            [self getFbIdStringArray:@"/me/friends"];
            break;
        }
    }
    
    if (self.type != userListTableViewTypeFBFriends) {
        [self getuserActionWithNewResponse:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getuserActionWithNewResponse:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getuserActionWithNewResponse:NO];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: YES];
    
    //Reload right cell when follow/unfollow user at userProfile page and back to this page, not accurate indifferent type of tableViews
    if (self.selectedIndexPath) {
        if ([self.tableView numberOfRowsInSection:0] > self.selectedIndexPath.row) {
            [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.type) {
        case userListTableViewTypeAllUsers: {
            return self.showSearchResults ? self.filtedArray.count + 3 : self.usersArray.count + 3;
            break;
        }
        case userListTableViewTypeMentions: {
            return self.showSearchResults ? self.filtedArray.count : self.usersArray.count;
            break;
        }
        case userListTableViewTypeFBFriends: {
            return self.usersArray.count + 1;
            break;
        }
        default:
            return self.usersArray.count;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == userListTableViewTypeAllUsers) {
        if (indexPath.row == 0) {
            UITableViewCell *fbCell = [tableView dequeueReusableCellWithIdentifier:@"fbCell" forIndexPath:indexPath];
            return fbCell;
        } else if (indexPath.row == 1) {
            UITableViewCell *contactCell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
            return contactCell;
        }else if (indexPath.row == 2) {
            UITableViewCell *pendingCell = [tableView dequeueReusableCellWithIdentifier:@"pendingCell" forIndexPath:indexPath];
            return pendingCell;
        }else {
            DwinkUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dwinkCell" forIndexPath:indexPath];
            [cell loadUserData:self.showSearchResults ? self.filtedArray[indexPath.row - 3] : self.usersArray[indexPath.row - 3]];
            return cell;
        }
    } else if (self.type == userListTableViewTypeMentions) {
        MentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mentionCell" forIndexPath:indexPath];
        [cell loadData:self.showSearchResults ? self.filtedArray[MIN(self.filtedArray.count - 1, indexPath.row)] : self.usersArray[MIN(self.usersArray.count - 1, indexPath.row)]];
        return cell;
    } else if (self.type == userListTableViewTypeFBFriends) {
        if (indexPath.row == 0) {
            UITableViewCell *fbInviteCell = [tableView dequeueReusableCellWithIdentifier:@"inviteFbCell" forIndexPath:indexPath];
            return fbInviteCell;
        } else {
            DwinkUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dwinkCell" forIndexPath:indexPath];
            [cell loadUserData: self.usersArray[indexPath.row - 1]];
            return cell;
        }
    } else {
        DwinkUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dwinkCell" forIndexPath:indexPath];
        [cell loadUserData: self.usersArray[indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == userListTableViewTypeAllUsers) {
        if (indexPath.row == 0) {
            //If user is not logged in with Facebook, make user login via facebook first then call fbFriends conrtoller
            UserInfo *sharedInfo = [UserInfo sharedInstance];
            if (!sharedInfo.fbId) {
                FBSDKLoginManager *fbLoginManager = [[FBSDKLoginManager alloc]init];
                [fbLoginManager logOut];
                [FBSDKLoginManager renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
                    
                }];
                
                [fbLoginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [CustomAlertController showCancelAlertControllerWithTitle:error.localizedDescription message:nil action:nil target:self];
                        });
                    } else {
                        if (result.isCancelled) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.indicator hide:YES];
                                [CustomAlertController showCancelAlertControllerWithTitle:@"Facebook Error" message:@"Authorization is cancelled" action:nil target:self];
                            });
                            return;
                        }
                        sharedInfo.fbId = result.token.userID;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self transitionToFBFriendsVC];
                        });
                    }
                }];
            } else {
                [self transitionToFBFriendsVC];
            }
        } else if (indexPath.row > 2) {
            UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
            self.selectedIndexPath = indexPath;
            DwinkUsersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            userInfoVC.viewModel.userInfo = cell.userInfo;
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
    } else if (self.type == userListTableViewTypeMentions) {
        MentionTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.mentionDelegate didFinishGotMentionUserName:cell.userInfo];
        }];
    } else if (self.type == userListTableViewTypeFBFriends) {
        if (indexPath.row == 0) {
            FBSDKAppInviteContent *content = [[FBSDKAppInviteContent alloc]init];
            content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1753194504954061"];
            FBSDKAppInviteDialog *diag = [FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
            if ([diag canShow]) {
                [diag show];
            }
        } else {
            UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
            self.selectedIndexPath = indexPath;
            DwinkUsersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            userInfoVC.viewModel.userInfo = cell.userInfo;
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
    } else {
        UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
        self.selectedIndexPath = indexPath;
        DwinkUsersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        userInfoVC.viewModel.userInfo = cell.userInfo;
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.type == userListTableViewTypeAllUsers && (indexPath.row == 0 || indexPath.row == 1)) || (self.type == userListTableViewTypeFBFriends && indexPath.row == 0)) {
        return 57.0;
    } else if (self.type == userListTableViewTypeMentions) {
        return 54.0;
    } else {
        return 73.0;
    }
}

#pragma mark - SearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = self.type == userListTableViewTypeAllUsers;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.type == userListTableViewTypeMentions) {
        [self.socialAPI.currentDataTask cancel];
        if (searchText.length > 0) {
            self.showSearchResults = YES;
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName contains[cd] %@", searchText];
//            self.filtedArray = [self.usersArray filteredArrayUsingPredicate: predicate];
            
            [self.socialAPI resetFollowingSearchedURLString:self.userInfo.idStr searchText:searchText];
            [self getuserActionWithNewResponse:YES];
        } else {
            self.showSearchResults = NO;
            self.filtedArray = [[NSArray alloc]init];
        }
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    self.searchBar.showsCancelButton = NO;
    
    if (searchBar.text.length == 0) {
        self.showSearchResults = NO;
        if (self.type == userListTableViewTypeAllUsers) {
            if (!self.socialAPI.noMoreAllUsers) {
                [self.tableView.mj_footer resetNoMoreData];
            }
        } else if (self.type == userListTableViewTypeMentions) {
            if (!self.socialAPI.noMoreFollowingSearchedUsers) {
                [self.tableView.mj_footer resetNoMoreData];
            }
        }
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    self.showSearchResults = YES;
    if (self.type == userListTableViewTypeAllUsers) {
        [self.socialAPI resetSearchedUsersStringWithSearchText:searchBar.text];
        [self getuserActionWithNewResponse:YES];
    }
}

#pragma mark Facebook delegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    [CustomAlertController showCancelAlertControllerWithTitle:@"Failed to send invitation" message:nil action:nil target:self];
}

#pragma mark - Selectors

- (IBAction)followAction:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    DwinkUsersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.userInfo.isFollowing) {
        cell.button.showIndicator = YES;
        [SocialAPI unFollowUser:cell.userID successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.button.showIndicator = NO;
                cell.userInfo.isFollowing = NO;
                [cell.button setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.button.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Unfollow user error" message:nil action:nil target:self];
            });
        }];
    } else if (!cell.userInfo.isFollowing && !cell.userInfo.isPending) {
        cell.button.showIndicator = YES;
        [SocialAPI followUser:cell.userID successHandler:^(UserInfo *userInfo){
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.userInfo.isFollowing = userInfo.isFollowing;
                cell.userInfo.isPending = userInfo.isPending;
                cell.button.showIndicator = NO;
                if (userInfo.privateProfile && userInfo.isPending) {
                    [cell.button setImage:[UIImage imageNamed:@"pending"] forState:UIControlStateNormal];
                } else {
                    [cell.button setImage:[UIImage imageNamed:@"userFollowed"] forState:UIControlStateNormal];
                }
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.button.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Follow user error" message:nil action:nil target:self];
            });
        }];
    } else if (cell.userInfo.isPending) {
        cell.button.showIndicator = YES;
        [SocialAPI cancelPendingRequestTo:cell.userID successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                 cell.button.showIndicator = NO;
                [sender setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
                cell.userInfo.isFollowing = NO;
                cell.userInfo.isPending = NO;
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.button.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Cancel pending Request error" message:nil action:nil target:self];
            });
        }];
    }
    
}
- (void)getuserActionWithNewResponse: (BOOL)newResponse {
    if (newResponse) {
        if (self.type != userListTableViewTypeAllUsers) {
            [self.socialAPI resetFollowersString:self.userInfo.idStr isSelf:self.userInfo.isSelf];
            [self.socialAPI resetFollowingString:self.userInfo.idStr isSelf:self.userInfo.isSelf];
            [self.socialAPI resetLikesURLStrWithIdStr:self.userInfo.idStr];
            [self.socialAPI resetGetFBFriendsURLStringWithFBId:[self.fbIdArray componentsJoinedByString:@","]];
            if (self.type == userListTableViewTypeMentions && self.showSearchResults) {
                [self.socialAPI resetFollowingSearchedURLString:self.userInfo.idStr searchText:self.searchBar.text];
            }
        } else {
            if (!self.showSearchResults) {
                [self.socialAPI resetAllUserString];
            } else {
                [self.socialAPI resetSearchedUsersStringWithSearchText:self.searchBar.text];
            }
        }
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    if (self.showSearchResults) {
        if (self.filtedArray.count == 0) {
            [self.indicator show:YES];
        }
    } else if (self.usersArray.count == 0) {
        [self.indicator show:YES];
    }
    
    switch (self.type) {
        case userListTableViewTypeMentions:
        case userListTableViewTypeFollowings: {
            if (self.showSearchResults) {
                [self.socialAPI getFollowingSearchedUsersWithText:self.searchBar.text successHandler:^(NSArray<UserInfo *> *userInfoArray) {
                    [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:self.socialAPI.noMoreFollowingSearchedUsers];
                } failureHandler:^(NSString *errorString) {
                    [self handleErrorResponse:errorString];
                }];
            } else {
                [self.socialAPI getWhoTheUserIsFollowingWithSuccessBlock:^(NSArray<UserInfo *> *userInfoArray) {
                    [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreFollowingUsers];
                } failureHandler:^(NSString *errorString) {
                    [self handleErrorResponse:errorString];
                }];
            }
            
            break;
        }
        case userListTableViewTypeFollowers: {
            [self.socialAPI getUserFollowersWithSuccessHandler:^(NSArray<UserInfo *> *userInfoArray) {
                [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreFollowers];
            } failureHandler:^(NSString *errorString) {
                [self handleErrorResponse:@"Load data error"];
            }];
            
            break;
        }
        case userListTableViewTypeAllUsers: {
            if (self.showSearchResults) {
                [self.socialAPI getSearchedUserList:self.searchBar.text successHandler:^(NSArray<UserInfo *> *userInfoArray) {
                    [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreSearchedUsers];
                } failureHandler:^(NSString *errorString) {
                    [self handleErrorResponse:@"Load data error"];
                }];
                
            } else {
                [self.socialAPI getAllUsersWithSuccessBlock:^(NSArray<UserInfo *> *userInfoArray) {
                    [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreAllUsers];
                } failureHandler:^(NSString *errorString) {
                    [self handleErrorResponse:@"Load data error"];
                }];
            }
            
            break;
        }
        case userListTableViewTypeLikes: {
            [self.socialAPI getLikes:self.userInfo.idStr successHandler:^(NSArray<UserInfo *> *userInfoArray) {
                [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreLikesUsers];
            } failureHandler:^(NSString *errorString) {
                [self handleErrorResponse:@"Load data error"];
            }];
            break;
        }
        case userListTableViewTypeFBFriends: {
            [self.socialAPI getFBFriendsWithSuccessHandler:^(NSArray<UserInfo *> *userInfoArray) {
                [self loadUsersData:newResponse userInfoArray:userInfoArray noMoreAction:(self.socialAPI).noMoreFBFriends];
            } failureHandler:^(NSString *errorString) {
                [self handleErrorResponse:@"Load data error"];
            }];
            break;
        }
    }
}

- (void)cancelMentionsList {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initializeSearchBar {
    self.searchBar = [[UISearchBar alloc]init];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.keyboardAppearance = UIKeyboardTypeWebSearch;
    self.searchBar.placeholder = self.type == userListTableViewTypeMentions ? @"Search by fullname" : @"Search by email/username/name";
    self.searchBar.delegate = self;
    self.filtedArray = [[NSArray alloc]init];
    self.showSearchResults = NO;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)loadUsersData: (BOOL)newResponse userInfoArray: (NSArray<UserInfo *> *)userInfoArray noMoreAction: (BOOL)noMoreAction {
    if (newResponse) {
        if (self.showSearchResults) {
            self.filtedArray = userInfoArray;
        } else {
            self.usersArray = userInfoArray;
        }
    } else {
        if (self.showSearchResults) {
            self.filtedArray = [self.filtedArray arrayByAddingObjectsFromArray:userInfoArray];;
        } else {
            self.usersArray = [self.usersArray arrayByAddingObjectsFromArray:userInfoArray];
        }
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
        if (noMoreAction) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    });
}

- (void)handleErrorResponse: (NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator hide:YES];
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
        if (self.tableView.mj_footer.isRefreshing) {
            [self.tableView.mj_footer endRefreshing];
        }
        [CustomAlertController showCancelAlertControllerWithTitle:text message:nil action:nil target:self];
    });
}

- (void)getFbIdStringArray: (NSString *)pathString {
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:pathString parameters:nil HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSArray *data = result[@"data"];
                 if ([data isKindOfClass:[NSArray class]]) {
                     for (NSDictionary *dict in data) {
                         if ([dict isKindOfClass:[NSDictionary class]]) {
                             NSString *idString = dict[@"id"];
                             if (idString) {
                                 [self.fbIdArray addObject:idString];
                             }
                         }
                     }
                 }
                 NSDictionary *paging = result[@"paging"];
                 if ([paging isKindOfClass:[NSDictionary class]]) {
                     NSString *next = paging[@"next"];
                     if (next) {
                         [self getFbIdStringArray:next];
                     } else {
                         [self getuserActionWithNewResponse:YES];
                         return;
                     }
                 } else {
                     [self getuserActionWithNewResponse:YES];
                     return;
                 }
             } else {
                 [self getuserActionWithNewResponse:YES];
                 return;
             }
         }];
    }
}

- (void)transitionToFBFriendsVC {
    DwinkUsersTableViewController *fbFriends = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"DwinkTableViewController"];
    [fbFriends setUpUserInfo:[UserInfo sharedInstance] type:userListTableViewTypeFBFriends];
    [self.navigationController pushViewController:fbFriends animated:YES];
}

@end
