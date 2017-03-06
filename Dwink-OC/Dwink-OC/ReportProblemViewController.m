//
//  ReportProblemViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/4/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "ReportProblemViewController.h"
#import "FunctionAPI.h"
#import "UIKitCategories.h"

@interface ReportProblemViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *problemTextView;

@end

@implementation ReportProblemViewController

#pragma mark - viewController lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.problemTextView.layer.borderWidth = 2.0;
    self.problemTextView.layer.borderColor = [UIColor DwinkGrey].CGColor;
    self.problemTextView.text = @"Enter your problem here...";
    self.problemTextView.textColor = [UIColor lightGrayColor];
    self.problemTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)sendProcess {
    if (self.problemTextView.text.length == 0) {
        self.problemTextView.layer.borderColor = [UIColor DwinkRed].CGColor;
    } else {
        [FunctionAPI reportProblemWithText:self.problemTextView.text successHandler:^{
            [CustomAlertController showCancelAlertControllerWithTitle:@"Successfully problem submit" message:nil action:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            } target:self];
        } failureHandler:^(NSString *errorString) {
            [CustomAlertController showCancelAlertControllerWithTitle:@"Failed to submit problem" message:nil action:nil target:self];
        }];
    }
}

#pragma mark - textView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.problemTextView.layer.borderColor = [UIColor DwinkGrey].CGColor;
    if (self.problemTextView.textColor == [UIColor lightGrayColor]) {
        self.problemTextView.textColor = [UIColor blackColor];
        self.problemTextView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.problemTextView.text.length == 0) {
        self.problemTextView.textColor = [UIColor lightGrayColor];
        self.problemTextView.text = @"Enter your problem here...";
    }
}

- (IBAction)endMainViewEditing:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
