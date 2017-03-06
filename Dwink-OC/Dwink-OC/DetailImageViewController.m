//
//  DetailImageViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "DetailImageViewController.h"
#import "CustomAlertController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailImageViewController ()<UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<UIImage *> *imageArray;
@property (nonatomic) NSMutableArray<UIImageView *> *imageViewCollection;
@property (nonatomic) DetailImageViewModel *viewModel;

@end

@implementation DetailImageViewController

- (instancetype)initWithURLArray: (NSArray *)urlArray andCurrentIndex: (NSUInteger)currentIndex {
    self = [super init];
    if (self) {
        _urlStringArray = urlArray;
        _imageViewCollection = [[NSMutableArray alloc]init];
        _currentIndex = currentIndex;
        self.viewModel = [[DetailImageViewModel alloc]init];
    }
    return self;
}

- (instancetype)initWithImageArray: (NSMutableArray<UIImage *> *)imageArray andCurrentIndex: (NSUInteger)currentIndex delegate: (id<DetailImageVCDelegate>)target {
    self = [super init];
    if (self) {
        _imageViewCollection = [[NSMutableArray alloc]init];
        _imageArray = imageArray;
        _currentIndex = currentIndex;
        self.viewModel = [[DetailImageViewModel alloc]init];
        self.viewModel.delegate = target;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Necessary otherwise will draw background color to black after subviews loaded do have clear background for 1s
    switch (self.mode) {
        case detailImageModeSelf: {
            self.title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.currentIndex + 1, (unsigned long)self.imageArray.count];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissCurrentViewController)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlertController)];
            break;
        }
        case detailImageModeOthers: {
            self.title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.currentIndex + 1, (unsigned long)self.urlStringArray.count];
            break;
        }
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    [self configureScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)configureScrollView {
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
//    self.scrollView.maximumZoomScale = 2.0;
//    self.scrollView.minimumZoomScale = 1.0;
//    self.scrollView.clipsToBounds = YES;
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * self.currentIndex, 0) animated:YES];
    switch (self.mode) {
        case detailImageModeSelf: {
            self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.imageArray.count, 0);
            for (int i = 0; i < self.imageArray.count; i++) {
                CGRect imageFrame = CGRectMake(SCREEN_WIDTH * i, -64, SCREEN_WIDTH, SCREEN_HEIGHT);
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageFrame];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.scrollView addSubview:imageView];
                imageView.image = self.imageArray[i];
                imageView.tag = i;
                [self.imageViewCollection addObject:imageView];
            }
            break;
        }
        case detailImageModeOthers: {
            self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.urlStringArray.count, 0);
            for (int i = 0; i < self.urlStringArray.count; i++) {
                CGRect imageFrame = CGRectMake(SCREEN_WIDTH * i, -64, SCREEN_WIDTH, SCREEN_HEIGHT);
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageFrame];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.scrollView addSubview:imageView];
                imageView.tag = i;
                [imageView sd_setImageWithURL:[NSURL URLWithString:self.urlStringArray[i]] placeholderImage:[UIImage imageNamed:@"noPicture"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!image) {
                        imageView.image = [UIImage imageNamed:@"errorpage"];
                    }
                }];
                [self.imageViewCollection addObject:imageView];
            }
            break;
        }
    }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = (NSInteger)scrollView.contentOffset.x/SCREEN_WIDTH;
    self.title = self.mode == detailImageModeSelf ?
    [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.currentIndex + 1, (unsigned long)self.imageArray.count] :
    [NSString stringWithFormat:@"%lu/%lu", (unsigned long)self.currentIndex + 1, (unsigned long)self.urlStringArray.count];
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.imageViewCollection[self.currentIndex];
//}

#pragma mark - Selectors

- (void)dismissCurrentViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDeleteAlertController {
    [CustomAlertController showConfirmAlertControllerWithTitle:@"Are you sure to delete this image?" message:nil confirmText:@"Delete" action:^(UIAlertAction *action) {
        for (UIImageView *imageView in self.imageViewCollection) {
            if (imageView.frame.origin.x == SCREEN_WIDTH * self.currentIndex) {
                if ([self.viewModel.delegate respondsToSelector:@selector(didClickDeleteButtonForImageAtIndex:)]) {
                    [self.viewModel.delegate didClickDeleteButtonForImageAtIndex:imageView.tag];
                }
                [self dismissViewControllerAnimated: YES completion:nil];
            }
        }
    } target:self];
}

@end
