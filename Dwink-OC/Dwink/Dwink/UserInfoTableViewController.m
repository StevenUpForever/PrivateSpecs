//
//  UserInfoTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/21/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "UserInfoTableViewCell.h"
#import "CommentTableViewCell.h"
#import "LoadingTableViewCell.h"
#import "SocialTableViewConfigure.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "FollowButton.h"
#import "PointsViewController.h"
#import "DwinkUsersTableViewController.h"
#import "CommentModel.h"
#import "DesignableUIKit.h"
#import "CustomIndicator.h"
#import "UserInfoNotification.h"
#import "DetailImageViewController.h"
#import "DetailImageNavController.h"
#import "UserInfo.h"
#import <MJRefresh/MJRefresh.h>

@interface UserInfoTableViewController ()<CellDelegate, CommentCellDelegate, mentionCellDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (nonatomic) NSLayoutConstraint *bottomConstraint;

@property (weak, nonatomic) IBOutlet CustomTextField *commentTextField;

@property (strong, nonatomic) IBOutlet UIView *pendingView;

@property (nonatomic) CustomIndicator *indicator;

@property (nonatomic) SocialAPI *socialAPI;

@end

@implementation UserInfoTableViewController

- (void)setUp: (UserInfo *)userInfo type: (userInfoVCType)type {
    [self.viewModel setUp:userInfo type:type];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.viewModel = [[UserInformationViewModel alloc]init];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.viewModel = [[UserInformationViewModel alloc]init];
    }
    return self;
}

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeViewControllerUI];
    [self initialzeTableViewUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUserInfo)
                                                 name:kBeginRefreshUI
                                               object:nil];
    [self initializeCommentViewUI];
    
    if ([[UserInfoNotification notificationCenter] needRefreshUI:self]) {
        [self refreshUserInfo];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kBeginRefreshUI
                                                  object:nil];
    [self.commentView removeFromSuperview];
}

#pragma mark - Table view data source & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsFromViewModel:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UserInfoTableViewCell *userInfoCell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell"];
        [userInfoCell loadDataWithInfo:self.viewModel.userInfo];
        return userInfoCell;
    } else if (indexPath.row == 1) {
        return [SocialTableViewConfigure reuseDifferentTableViewCellForUserInfoPage:self.viewModel.userInfo tableView:tableView delegate:self];
    } else {
        if (self.viewModel.needToLoadRefreshCell) {
            LoadingTableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
            return loadingCell;
        } else {
            CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
            [commentCell loadData:[self.viewModel currentComment:indexPath]];
            commentCell.delegate = self;
            return commentCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel estimateHeightforCellAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 1 && self.viewModel.commentsHadLoaded) {
        CommentTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.model.isSelf) {
            [self deleteCommentCellAtIndexPath:indexPath];
        } else {
            self.viewModel.currentCommentModel = cell.model;
            [self.commentTextField becomeFirstResponder];
            self.commentTextField.placeholder = cell.model.commentViewPlaceHolder;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 1 && self.viewModel.commentsHadLoaded) {
        CommentTableViewCell *commentCell = [tableView cellForRowAtIndexPath:indexPath];
        return commentCell.model.isSelf ? YES : NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCommentCellAtIndexPath:indexPath];
    }
}

#pragma mark - TextField delegate & Selectors

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.placeholder = nil;
        self.viewModel.currentCommentModel = nil;
    }
    self.viewModel.tempCommentString = nil;
}

- (void)didChangeTheInputValue: (UITextField *)textField {
    if ([textField.text isEqualToString: @"@"] && self.viewModel.tempCommentIsInvalid) {
        DwinkUsersTableViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"DwinkTableViewController"];
        [tableViewController setUpUserInfo:[UserInfo sharedInstance] type:userListTableViewTypeMentions];
        tableViewController.mentionDelegate = self;
        UINavigationController *mentionNav = [[UINavigationController alloc]initWithRootViewController:tableViewController];
        [self presentViewController:mentionNav animated:YES completion:nil];
    }
    self.viewModel.tempCommentString = textField.text;
}

#pragma mark - cell delegate

- (void)didClickImageViewOnCell:(NSArray *)urlStrArray currentIndex:(NSUInteger)index {
    DetailImageViewController *detailVC = [[DetailImageViewController alloc]initWithURLArray:urlStrArray andCurrentIndex:index];
    DetailImageNavController *navCon = [[DetailImageNavController alloc]initWithRootController:detailVC mode:detailImageModeOthers];
    [self.view.window.rootViewController presentViewController:navCon animated:YES completion:nil];
}

- (void)didClickLikesLabel:(UserInfo *)userInfo {
    if (userInfo.post.likesCount > 0) {
        [self showUserListTableViewController:userListTableViewTypeLikes];
    }
}

- (void)commentCellAvatarLabelClicked:(UserInfo *)userInfo {
    UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
    [userInfoVC setUp:userInfo type:userInfoVCTypeHomeFeed];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)didFinishGotMentionUserName:(UserInfo *)userInfo {
    self.commentTextField.text = [NSString stringWithFormat:@"@%@ ", userInfo.userName];
}

#pragma mark - custom selectors

- (void)refreshUserInfo {
    if (self.viewModel.userInfo.isSelf) {
        [SocialAPI getCurrentUserWithSuccessBlock:^(UserInfo *sharedUserInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.viewModel.userInfo = sharedUserInfo;
                self.navigationItem.title = self.viewModel.userInfo.fullName;
                [self.tableView reloadData];
                [self endRefreshHeaderAndFooter];
                [[UserInfoNotification notificationCenter] finishRefreshUI:self];
            });
        } failureHandler:^(NSString *errorString) {
            [self endRefreshHeaderAndFooter];
            [CustomAlertController showCancelAlertControllerWithTitle:@"Refresh page error" message:errorString action:nil target:self];
        }];
    } else {
        [SocialAPI getIndicateUserWithIdStr:self.viewModel.userInfo.idStr successHandler:^(UserInfo *userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareForFooterView];
                self.viewModel.userInfo = userInfo;
                self.navigationItem.title = self.viewModel.userInfo.fullName;
                [self.tableView reloadData];
                [self endRefreshHeaderAndFooter];
            });
        } failureHandler:^(NSString *errorString) {
            [self endRefreshHeaderAndFooter];
            [CustomAlertController showCancelAlertControllerWithTitle:@"Refresh page error" message:errorString action:nil target:self];
        }];
    }    [self getCommentDataWithNewResponse:YES];
}

- (void)getCommentDataWithNewResponse: (BOOL)newResponse {
    if (newResponse) {
        [self.socialAPI resetCommentsURLStringWithIdStr:self.viewModel.userInfo.idStr];
        [self.tableView.mj_footer resetNoMoreData];
    }
    [self.socialAPI getCommentsWithSuccessHandler:^(NSArray<CommentModel *> *commentArray) {
        [self.viewModel processCommentDataDependsOnResponse:newResponse commentArray:commentArray];
        MJRefreshBackNormalFooter *footer = (MJRefreshBackNormalFooter *)self.tableView.mj_footer;
        footer.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if (self.viewModel.shouldScrollTableView) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                self.viewModel.shouldScrollTableView = NO;
            }
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            if (self.socialAPI.noMoreComments) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        });
    } failureHandler:^(NSString *errorString) {
        [CustomAlertController showCancelAlertControllerWithTitle:nil message:@"Failed to fetch comments" action:nil target:self];
    }];
}

- (void)keyboardWillShow: (NSNotification *)aNotification {
    CGRect keyboardFrame = [self.viewModel tableViewOffsetNeeded:aNotification];
    if (keyboardFrame.size.height == 0) {
        return;
    }
    
    NSNumber *durition = (aNotification.userInfo)[UIKeyboardAnimationDurationUserInfoKey];
    self.bottomConstraint.constant = -49;
    self.bottomConstraint.constant -= keyboardFrame.size.height - 49;
    [UIView animateWithDuration:durition.doubleValue animations:^{
        [self.navigationController.view layoutIfNeeded];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, keyboardFrame.size.height + self.commentView.frame.size.height, 0.0);
        self.tableView.contentInset = contentInsets;
    }];
    NSInteger row = [self.viewModel lastRowOfTableView:[self.tableView numberOfRowsInSection:0] - 1];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide: (NSNotification *)aNotification {
    self.bottomConstraint.constant = -49;
    CGRect keyboardFrame = [self.viewModel tableViewOffsetNeeded:aNotification];
    [UIView animateWithDuration:UIKeyboardAnimationDurationUserInfoKey.doubleValue animations:^{
        [self.navigationController.view layoutIfNeeded];
        self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, keyboardFrame.size.height + self.commentView.frame.size.height + 49, 0.0);
    }];
}

- (void)userInfoEndEditing {
    [self.navigationController.view endEditing:YES];
    [self.view endEditing:YES];
}

- (void)deleteCommentCellAtIndexPath: (NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Do you want to delete this comment?" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        CommentTableViewCell *commentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [SocialAPI deleteComment:commentCell.model.userInfo.idStr commentId:commentCell.model.commentId successHandler:^{
            
        } failureHandler:^(NSString *errorString) {
            
        }];
        [self.viewModel removeDataFromCommentArray:commentCell.model completionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            });
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)avatarButtonAction:(FollowButton *)sender {
    if (self.viewModel.userInfo.isSelf) {
        [self performSegueWithIdentifier:@"editProfile" sender:self];
    } else if (self.viewModel.userInfo.isFollowing) {
        sender.showIndicator = YES;
        [SocialAPI unFollowUser:self.viewModel.userInfo.idStr successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                [sender setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
                self.viewModel.userInfo.isFollowing = NO;
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Unfollow user error" message:errorString action:nil target:self];
            });
        }];
    } else if (self.viewModel.userInfo.isPending) {
        sender.showIndicator = YES;
        [SocialAPI cancelPendingRequestTo:self.viewModel.userInfo.idStr successHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                [sender setImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
                self.viewModel.userInfo.isFollowing = NO;
                self.viewModel.userInfo.isPending = NO;
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Cancel pending Request error" message:nil action:nil target:self];
            });
        }];
    } else if (!self.viewModel.userInfo.isFollowing) {
        sender.showIndicator = YES;
        [SocialAPI followUser:self.viewModel.userInfo.idStr successHandler:^(UserInfo *userInfo){
            self.viewModel.userInfo = userInfo;
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                if (userInfo.privateProfile && userInfo.isPending) {
                    [sender setImage:[UIImage imageNamed:@"pending"] forState:UIControlStateNormal];
                } else {
                    [sender setImage:[UIImage imageNamed:@"userFollowed"] forState:UIControlStateNormal];
                }
            });
        } failureHandler:^(NSString *errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.showIndicator = NO;
                [CustomAlertController showCancelAlertControllerWithTitle:@"Follow user error" message:errorString action:nil target:self];
            });
        }];
    }
}

- (IBAction)followersAction:(UITapGestureRecognizer *)sender {
    [self showUserListTableViewController:userListTableViewTypeFollowers];
}

- (IBAction)followingsAction:(UITapGestureRecognizer *)sender {
    [self showUserListTableViewController:userListTableViewTypeFollowings];
}

- (IBAction)postComment:(CustomButton *)sender {
    if (self.commentTextField.text.length == 0) {
        [CustomAlertController showCancelAlertControllerWithTitle:nil message:@"Please enter your comment" action:nil target:self];
    } else {
        NSString *commentStr = [self.viewModel createCompleteCommentString:self.commentTextField.text];
        [SocialAPI postNewComments:self.viewModel.userInfo.idStr commentStr:commentStr successHandler:^(CommentModel *comment) {
            [self.viewModel getInsertRowAndAddObjectForCommentDataSource:comment completionHandler:^(NSInteger insertRow, BOOL shouldLoadMoreComments) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    self.viewModel.currentCommentModel = nil;
                });
            }];
        } failureHandler:^(NSString *errorString) {
            [CustomAlertController showCancelAlertControllerWithTitle:@"Failed to post comment" message:nil action:nil target:self];
        }];
        self.commentTextField.text = nil;
        [self.commentTextField resignFirstResponder];
    }
}

#pragma mark - Other methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPoints"]) {
        PointsViewController *pointsVC = segue.destinationViewController;
        pointsVC.pointsStr = [NSString stringWithFormat:@"%li", (long)self.viewModel.userInfo.points];
    }
}

- (void)showUserListTableViewController: (userListTableViewType)type {
    DwinkUsersTableViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"DwinkTableViewController"];
    [tableViewController setUpUserInfo:self.viewModel.userInfo type:type];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

#pragma mark - Private methods

- (void)initializeViewControllerUI {
    self.navigationItem.title = self.viewModel.userInfo.fullName;
    
    self.socialAPI = [[SocialAPI alloc]initWithIdStr:self.viewModel.userInfo.idStr isSelf:[[UserInfo sharedInstance].idStr isEqualToString:self.viewModel.userInfo.idStr]];
    
    self.indicator = [CustomIndicator newInstanceForView:self.tableView];
    
    [self.commentTextField addTarget:self action:@selector(didChangeTheInputValue:) forControlEvents:UIControlEventEditingChanged];
    self.commentTextField.delegate = self;
}

- (void)initialzeTableViewUI {
    [self.tableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"commentCell"];
    self.pendingView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height -330.0);
    [self prepareForFooterView];
    (self.tableView).contentInset = UIEdgeInsetsMake(0.0, 0.0, 65.0, 0.0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [SocialTableViewConfigure registerAllKindsOfPostTableViewCell:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshUserInfo];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getCommentDataWithNewResponse:NO];
    }];
    MJRefreshBackNormalFooter *footer = (MJRefreshBackNormalFooter *)self.tableView.mj_footer;
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    footer.stateLabel.userInteractionEnabled = NO;
    footer.userInteractionEnabled = NO;
    
    self.commentView.hidden = !self.viewModel.userInfo.isSelf && !self.viewModel.userInfo.isFollowing && self.viewModel.userInfo.privateProfile;
    
    [self getCommentDataWithNewResponse:YES];
    
}

- (void)initializeCommentViewUI {
    [self.navigationController.view addSubview:self.commentView];
    self.commentView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.commentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.commentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-49.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.commentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *widthHeightConstraint = [NSLayoutConstraint constraintWithItem:self.commentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.commentView attribute:NSLayoutAttributeHeight multiplier:375.0/53.0 constant:0.0];
    [self.navigationController.view addConstraints:@[leftConstraint, self.bottomConstraint, rightConstraint, widthHeightConstraint]];
}

- (void)endRefreshHeaderAndFooter {
    if (self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header endRefreshing];
    }
    if (self.tableView.mj_footer.isRefreshing) {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)prepareForFooterView {
    if (!self.viewModel.userInfo.isSelf && !self.viewModel.userInfo.isFollowing && self.viewModel.userInfo.privateProfile) {
        self.tableView.tableFooterView = self.pendingView;
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

@end
