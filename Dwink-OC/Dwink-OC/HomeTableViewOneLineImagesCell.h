//
//  HomeTableViewOneLineImagesCell.h
//  Dwink
//
//  Created by Chengzhi Jia on 7/10/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "HomeTableViewNoImageCell.h"
#import "HomeCellViewModel.h"

typedef NS_ENUM(NSUInteger, postCellNumberOfLines) {
    postCellNumberOfLinesOneLine,
    postCellNumberOfLinesTwoLines
};

@interface HomeTableViewOneLineImagesCell : HomeTableViewNoImageCell

@property (nonatomic, assign) postCellNumberOfLines numOfLines;

@end
