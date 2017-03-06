//
//  FoundationCategories.m
//  Dwink
//
//  Created by Steven Jia on 9/29/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "FoundationCategories.h"
#import "CommonAPI.h"

@implementation NSString (StringCategory)

//Valid email address by regular expression

- (BOOL)emailIsValid {
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *checkResult = [regular firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    return checkResult == nil ? NO : YES;
}

+ (NSString *)properStringWithInteger: (NSInteger)integer {
    if (integer < 1000) {
        return [self stringWithFormat:@"%li", (long)integer];
    } else if (integer < 1000000) {
        return [self stringWithFormat:@"%.1fK",(double)integer/1000];
    } else {
        return [self stringWithFormat:@"%.1fM", (double)integer/1000000];
    }
}

- (NSDate *)convertISO8601String {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    return [dateFormatter dateFromString:self];
}

- (NSString *)setChannelIdStr {
    return [NSString stringWithFormat:@"user%@", self];
}

- (NSString *)getKeyStrFromURLStr {
    NSString *mainFormat = [NSString stringWithFormat:@"%@/", S3MainEndPoint];
    if ([self containsString:mainFormat]) {
        return [self stringByReplacingOccurrencesOfString:mainFormat withString:@""];
    } else {
        return self;
    }
}

- (void)createURLFullNameStringWithCompletionHandler: (void(^)(NSString *result, NSError *error))completionHandler {
    NSError *error = nil;
    NSString *trimStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *resultStr = [regex stringByReplacingMatchesInString:trimStr options:0 range:NSMakeRange(0, trimStr.length) withTemplate:@"%20"];
    if (completionHandler) {
        completionHandler(resultStr, error);
    }
}

@end

@implementation NSDate (DateCategory)

- (NSString *)fetchElapsedString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self toDate:[NSDate date] options:0];
    return [self retriveDateStringFromDateComponents:components];
}

+ (NSString *)currentDateIdentifier {
    NSDate *date = [self date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM-dd-hh:mm:ss";
    return [formatter stringFromDate:date];
}

#pragma mark - Private methods

- (NSString *)retriveDateStringFromDateComponents: (NSDateComponents *)components {
    if (components.year > 0) {
        switch (components.year) {
            case 1:
                return @"1 year ago";
                break;
                
            default:
                return [NSString stringWithFormat:@"%li years ago", (long)components.year];
                break;
        }
    } else if (components.month > 0) {
        switch (components.month) {
            case 1:
                return @"1 month ago";
                break;
                
            default:
                return [NSString stringWithFormat:@"%li months ago", (long)components.month];
                break;
        }
    } else if (components.day > 0) {
        switch (components.day) {
            case 1:
                return @"1 day ago";
                break;
                
            default:
                return [NSString stringWithFormat:@"%li days ago", (long)components.day];
                break;
        }
    } else if (components.hour > 0) {
        switch (components.hour) {
            case 1:
                return @"1 hour ago";
                break;
                
            default:
                return [NSString stringWithFormat:@"%li hours ago", (long)components.hour];
                break;
        }
    } else if (components.minute > 0) {
        switch (components.minute) {
            case 1:
                return @"1 minute ago";
                break;
                
            default:
                return [NSString stringWithFormat:@"%li minutes ago", (long)components.minute];
                break;
        }
    } else {
        return @"Just now";
    }
}

@end


