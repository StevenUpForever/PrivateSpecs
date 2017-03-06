//
//  FoundationCategories.h
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringCategory)

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL emailIsValid;

+ (NSString *)properStringWithInteger: (NSInteger)integer;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *convertISO8601String;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *setChannelIdStr;

@property (NS_NONATOMIC_IOSONLY, getter=getKeyStrFromURLStr, readonly, copy) NSString *keyStrFromURLStr;

- (void)createURLFullNameStringWithCompletionHandler: (void(^)(NSString *result, NSError *error))completionHandler;

@end

@interface NSDate (DateCategory)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *fetchElapsedString;

+ (NSString *)currentDateIdentifier;

@end

