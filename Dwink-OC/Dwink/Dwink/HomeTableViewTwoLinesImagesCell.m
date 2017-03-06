//
//  HomeTableViewCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/2/28.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "HomeTableViewTwoLinesImagesCell.h"

@interface HomeTableViewTwoLinesImagesCell()

@end

@implementation HomeTableViewTwoLinesImagesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self.numOfLines = postCellNumberOfLinesTwoLines;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

@end
