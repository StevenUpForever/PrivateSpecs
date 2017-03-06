//
//  PointsViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 8/17/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "PointsViewController.h"

@interface PointsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@end

@implementation PointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Points";
    self.pointsLabel.text = self.pointsStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end