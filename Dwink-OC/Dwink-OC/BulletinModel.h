//
//  BulletinModel.h
//  Dwink
//
//  Created by Chengzhi Jia on 9/2/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BulletinModel;
@protocol BulletinCellDelegate <NSObject>

- (void)didClickTriggererAction: (BulletinModel *)model;

@end

@interface BulletinModel : NSObject

@property (nonatomic, readonly, copy) NSString *actionStr;
@property (nonatomic, readonly, copy) NSString *elapsedStr;
@property (nonatomic, readonly, copy) NSString *targetStr;
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *fullname;
@property (nonatomic, readonly, copy) NSString *triggererId;
@property (nonatomic, readonly, copy) NSString *actionId;
@property (nonatomic, readonly, copy) NSString *type;

- (void)loadData: (NSDictionary *)dict;

@end
