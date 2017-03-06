//
//  DetailImageNavController.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "DetailImageNavController.h"
#import "DetailImageViewController.h"

@interface DetailImageNavController ()

@end

@implementation DetailImageNavController

- (instancetype)initWithRootController: (UIViewController *)rootVC mode: (detailImageMode)mode {
    self = [super initWithRootViewController:rootVC];
    if (self) {
        switch (mode) {
            case detailImageModeSelf: {
                break;
            }
            case detailImageModeOthers: {
                [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCurrentViewController)]];
                break;
            }
        }
        self.mode = mode;
        if ([rootVC isMemberOfClass:[DetailImageViewController class]]) {
            DetailImageViewController *detailVC = (DetailImageViewController *)rootVC;
            detailVC.mode = mode;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    (self.navigationBar).shadowImage = [UIImage new];
    [self.navigationBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

- (void)dismissCurrentViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
