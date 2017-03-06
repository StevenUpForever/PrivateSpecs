//
//  ContactsTableViewCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@interface ContactsTableViewCell : UITableViewCell

@property (nonatomic) CNContact *contact;

- (void)loadContactsData: (CNContact *)contact;

@end
