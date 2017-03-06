//
//  UserInfoTableViewController+UserInfoDelegateCategory.m
//  Dwink
//
//  Created by Steven Jia on 9/30/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "UserInfoTableViewController+UserInfoDelegateCategory.h"
#import "DwinkUsersTableViewController.h"
#import "DetailImageViewController.h"
#import "DetailImageNavController.h"

@implementation UserInfoTableViewController (UserInfoDelegateCategory)

#pragma mark - ScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self userInfoEndEditing];
}

#pragma mark - TextField delegate & Selectors

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.placeholder = nil;
        self.viewModel.currentCommentModel = nil;
    }
    self.tempCommentString = nil;
}

- (void)didChangeTheInputValue: (UITextField *)textField {
    if ([textField.text isEqualToString: @"@"] && self.tempCommentString.length == 0) {
        DwinkUsersTableViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil]instantiateViewControllerWithIdentifier:@"DwinkTableViewController"];
        [tableViewController setUpUserInfo:[UserInfo sharedInstance] type:userListTableViewTypeMentions];
        tableViewController.mentionDelegate = self;
        UINavigationController *mentionNav = [[UINavigationController alloc]initWithRootViewController:tableViewController];
        [self presentViewController:mentionNav animated:YES completion:nil];
    }
    self.tempCommentString = textField.text;
}

#pragma mark - cell delegate

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

- (void)didClickLikesLabel:(UserInfo *)userInfo {
    if (userInfo.post.likesCount > 0) {
        [self showUserListTableViewController:userListTableViewTypeLikes];
    }
}

- (void)commentCellAvatarLabelClicked:(UserInfo *)userInfo {
    UserInfoTableViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"CustomStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"userInfoTableView"];
    userInfoVC.userInfo = userInfo;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)didFinishGotMentionUserName:(UserInfo *)userInfo {
    self.commentTextField.text = [NSString stringWithFormat:@"@%@ ", userInfo.userName];
}

#pragma mark - custom selectors

- (void)refreshUserInfo {
    if (self.userInfo.isSelf) {
        [SocialAPI getCurrentUserWithSuccessBlock:^(UserInfo *sharedUserInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInfo = sharedUserInfo;
                self.navigationItem.title = self.userInfo.fullName;
                [self.tableView reloadData];
                if (self.tableView.mj_header.isRefreshing) {
                    [self.tableView.mj_header endRefreshing];
                }
                [[UserInfoNotification notificationCenter] finishRefreshUI:self];
            });
        } failureHandler:^(NSString *errorString) {
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            [CustomAlertController showCancelAlertControllerWithTitle:@"Refresh page error" message:errorString action:nil target:self];
        }];
    } else {
        [SocialAPI getIndicateUserWithIdStr:self.userInfo.idStr successHandler:^(UserInfo *userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInfo = userInfo;
                self.navigationItem.title = self.userInfo.fullName;
                [self.tableView reloadData];
                if (self.tableView.mj_header.isRefreshing) {
                    [self.tableView.mj_header endRefreshing];
                }
            });
        } failureHandler:^(NSString *errorString) {
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            [CustomAlertController showCancelAlertControllerWithTitle:@"Refresh page error" message:errorString action:nil target:self];
        }];
    }
    [self getCommentData];
}

- (void)getCommentData {
    [SocialAPI getComments:self.userInfo.idStr successHandler:^(NSArray<CommentModel *> *commentArray) {
        self.commentArray = [[NSMutableArray alloc]initWithArray:commentArray];
        self.finishLoadComment = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if (self.commentArray.count > 0 && self.shouldScrollToComments) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                self.shouldScrollToComments = NO;
            }
        });
    } failureHandler:^(NSString *errorString) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"Failed to fetch comments" message:nil action:nil target:self];
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
        [self.commentView layoutIfNeeded];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, keyboardFrame.size.height + self.commentView.frame.size.height, 0.0);
        self.tableView.contentInset = contentInsets;
    }];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.commentArray.count + 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide: (NSNotification *)aNotification {
    self.bottomConstraint.constant = -49;
    CGRect keyboardFrame = [self.viewModel tableViewOffsetNeeded:aNotification];
    [UIView animateWithDuration:UIKeyboardAnimationDurationUserInfoKey.doubleValue animations:^{
        [self.commentView layoutIfNeeded];
        self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, keyboardFrame.size.height + self.commentView.frame.size.height + 49, 0.0);
    }];
}

- (void)userInfoEndEditing {
    [self.navigationController.view endEditing:YES];
    [self.view endEditing:YES];
}

- (void)deleteCommentCellAtIndexPath: (NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure to delete this comment" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        CommentTableViewCell *commentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [SocialAPI deleteComment:commentCell.model.userInfo.idStr commentId:commentCell.model.commentId successHandler:^{
            
        } failureHandler:^(NSString *errorString) {
            
        }];
        if ([self.commentArray containsObject:commentCell.model]) {
            [self.commentArray removeObject:commentCell.model];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            });
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
