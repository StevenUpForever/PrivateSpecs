//
//  BulletinModel.m
//  Dwink
//
//  Created by Chengzhi Jia on 9/2/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "BulletinModel.h"
#import "FoundationCategories.h"

@interface BulletinModel()

@property (nonatomic, copy) NSString *recipientId;
@property (nonatomic, copy) NSString *subjectId;

@end

@implementation BulletinModel

- (void)loadData: (NSDictionary *)dict {
    _actionStr = dict[@"action"];
    NSString *dateStr = dict[@"created_at"];
    NSDate *convertedDate = dateStr.convertISO8601String;
    if (convertedDate) {
        _elapsedStr = convertedDate.fetchElapsedString;
    }
    _targetStr = dict[@"target"];
    _username = dict[@"username"];
    _triggererId = dict[@"triggerer_id"];
    _recipientId = dict[@"recipient_id"];
    _subjectId = dict[@"subject_id"];
    _type = dict[@"type"];
    _actionId = [self convertActionStr:self.type];
}

- (NSString *)convertActionStr: (NSString *)type {
    //UserFollowed, PostComment, CommentMentioned, PostMentioned, PostLiked
    if ([type isEqualToString:@"CommentMentioned"] || [type isEqualToString:@"PostMentioned"]) {
        return self.subjectId;
    } else {
        return self.recipientId;
    }
}



@end
