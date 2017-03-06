//
//  HomeTableViewOneLineImagesCell.m
//  Dwink
//
//  Created by Chengzhi Jia on 7/10/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "HomeTableViewOneLineImagesCell.h"

@interface HomeTableViewOneLineImagesCell()

@property (nonatomic) NSArray<UIImageView *> *imageViewCollection;

@end

@implementation HomeTableViewOneLineImagesCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.numOfLines = postCellNumberOfLinesOneLine;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.postViewHeight uninstall];
        [self layoutPostViews];
    }
    return self;
}

- (void)loadCellDataWithInfo:(UserInfo *)info {
    
    [super loadCellDataWithInfo:info];
    
    [self.viewModel loadImageCollection:self.imageViewCollection];
}

#pragma mark - Private methods

- (void)layoutPostViews {
    switch (self.numOfLines) {
        case postCellNumberOfLinesOneLine: {
            [self addImageViews:3];
            break;
        }
        case postCellNumberOfLinesTwoLines: {
            [self addImageViews:6];
            break;
        }
    }
}

- (void)addImageViews: (NSUInteger)count {
    NSMutableArray<UIImageView *> *tempImageViewCollection = [[NSMutableArray alloc]init];
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.tag = i;
        [self.postView addSubview:imageView];
        [tempImageViewCollection addObject:imageView];
    }
    self.imageViewCollection = [NSArray arrayWithArray:tempImageViewCollection];
    [self layoutImageViews:count];
}

- (void)layoutImageViews: (NSUInteger)numOfLines {
    [self.imageViewCollection enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        obj.tag = idx;
        [self.viewModel addGestureForOneImageView:obj];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0 || idx == 3) {
                make.leading.equalTo(self.postView.mas_leading).offset(0.0);
            } else {
                make.leading.equalTo(self.imageViewCollection[idx - 1].mas_trailing).offset(2.0);
            }
            if (numOfLines > 3 && idx < 3) {
                make.bottom.equalTo(self.imageViewCollection[idx + 3].mas_top).offset(-2.0);
            } else {
                make.bottom.equalTo(self.postView.mas_bottom).offset(0.0);
            }
            if (idx < 3) {
                make.top.equalTo(self.postView.mas_top).offset(0.0);
            }
            if (idx == 2 || idx == 5) {
                make.trailing.equalTo(self.postView.mas_trailing).offset(0.0);
            }
            if (idx == 0) {
                make.width.equalTo(obj.mas_height).multipliedBy(1.0/1.0);
                NSArray<UIImageView *> *compareImageCollection = [self.imageViewCollection objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, numOfLines - 1)]];
                make.width.equalTo(compareImageCollection);
                make.height.equalTo(compareImageCollection);
            }
        }];
    }];
}

@end
