//
//  DetailImageViewController.h
//  Dwink
//
//  Created by Chengzhi Jia on 8/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailImageViewModel.h"

@class DetailImageNavController;
@interface DetailImageViewController : UIViewController

@property (nonatomic, copy) NSArray *urlStringArray;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign) detailImageMode mode;

/**
 *  Required initialization method when no creation in Interface builder file
 *
 *  @param urlArray     urlStringArray to load images in detailImageViewController
 *  @param currentIndex Current image which received user's event
 *  @warning            Must use this initialization when NO interface builder related to it
 *
 *  @return Intance object of DetailImageViewController
 */

- (instancetype)initWithURLArray: (NSArray *)urlArray andCurrentIndex: (NSUInteger)currentIndex;


/**
 Initialize imageController with local images

 @param imageArray   the array of UIImages to load in imageController
 @param currentIndex Current image which received user's event
 @param target       the target to perform and conform to delegate

 @return Intance object of DetailImageViewController
 */
- (instancetype)initWithImageArray: (NSMutableArray<UIImage *> *)imageArray andCurrentIndex: (NSUInteger)currentIndex delegate: (id<DetailImageVCDelegate>)target;

@end
