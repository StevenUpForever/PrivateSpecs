//
//  ImagePreviewViewController.m
//  Dwink
//
//  Created by Steven Jia on 9/6/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "Masonry.h"

@interface ImagePreviewViewController ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSelector)];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)saveSelector {
    [self.delegate didSaveImageButtonClicked:self.image imagePicker:self.imagePicker];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
