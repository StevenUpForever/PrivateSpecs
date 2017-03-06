//
//  ContactsTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "ContactsTableViewCell.h"

@interface ContactsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *contactImage;
@property (weak, nonatomic) IBOutlet UILabel *contactName;

@end

@implementation ContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.contactImage.layer.cornerRadius = self.contactImage.frame.size.width/2.0;
}

- (void)loadContactsData: (CNContact *)contact {
    self.contact = contact;
    self.contactImage.image = contact.imageData ? [UIImage imageWithData:contact.imageData] : [UIImage imageNamed:@"Me40"];
    self.contactName.text = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName];
}

@end
