//
//  DetailImageViewModel.h
//  Dwink
//
//  Created by Steven Jia on 9/2/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, detailImageMode) {
    detailImageModeSelf,
    detailImageModeOthers
};

@protocol DetailImageVCDelegate <NSObject>

@optional
- (void)didClickDeleteButtonForImageAtIndex: (NSUInteger)index;

@end

@interface DetailImageViewModel : NSObject

@property (weak, nonatomic) id<DetailImageVCDelegate> delegate;

@end
