//
//  ContactsTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "CustomAlertController.h"
#import "ContactsTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <Contacts/Contacts.h>

@interface ContactsTableViewController ()<UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) NSArray<CNContact *> *contactsArray;
@property (nonatomic) UIRefreshControl *refresh;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatContactArray];
    
    self.refresh = [[UIRefreshControl alloc]init];
    [self.refresh addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.refresh];
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
    return self.contactsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    [cell loadContactsData:self.contactsArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.0;
}

#pragma mark - Message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteProcess:(id)sender {
    if (![MFMessageComposeViewController canSendText]) {
        [CustomAlertController showCancelAlertControllerWithTitle:@"SMS not support" message:@"Your device doesn't support SMS" action:nil target:self];
    } else {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        ContactsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose phone number" message:@"Choose phone number which you want send message" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        for (CNLabeledValue *label in cell.contact.phoneNumbers) {
            NSString *valueStr = [label.value stringValue];
            if (valueStr.length > 0) {
                UIAlertAction *numberAction = [UIAlertAction actionWithTitle:valueStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc]init];
                    messageVC.recipients = @[valueStr];
                    messageVC.body = @"Try this new app called Dwink, it's super fun!\nhttps://itunes.apple.com/us/app/dwink-live-in-the-moment/id1104722386?mt=8";
                    messageVC.messageComposeDelegate = self;
                    [self presentViewController:messageVC animated:YES completion:nil];
                }];
                [alertController addAction:numberAction];
            }
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - selectors
- (void)refreshAction: (UIRefreshControl *)control {
    [self creatContactArray];
}

- (void)creatContactArray {
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:contactStore.defaultContainerIdentifier];
            NSError *error;
            NSArray *tempContactArray = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ((self.refresh).refreshing) {
                        [self.refresh endRefreshing];
                    }
                    [CustomAlertController showCancelAlertControllerWithTitle:@"Fetch Contact error" message:@"Cannot get contacts information, please try again" action:nil target:self];
                });
            } else {
                self.contactsArray = tempContactArray;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    if ((self.refresh).refreshing) {
                        [self.refresh endRefreshing];
                    }
                });
            }
        }
    }];
}

@end
