//
//  SignUpViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 12/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "SignUpViewController.h"
#import "CountrySelectTableViewController.h"
#import "CountrySelectTableViewCell.h"
#import "SignUpAPI.h"
#import "VerifyNumViewController.h"
#import <DigitsKit/DigitsKit.h>

@interface SignUpViewController ()<countrySelectDelegate, UITextFieldDelegate>

@property(nonatomic) countryModel *currentModel;
@property (weak, nonatomic) IBOutlet UILabel *numPrefix;
@property (weak, nonatomic) IBOutlet UILabel *unvalidNum;
@property (weak, nonatomic) IBOutlet UILabel *countryCode;
@property (weak, nonatomic) IBOutlet UITextField *numTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unvalidNum.hidden = YES;
    self.numTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButton:(UITapGestureRecognizer *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)nextProcess:(UIButton *)sender {
    if (self.numTextField.text.length == 0) {
        self.unvalidNum.hidden = NO;
    } else {
        [SignUpAPI validPhoneNumber:self.numTextField.text successHandler:^{
            
            Digits *digits = [Digits sharedInstance];
            DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
            configuration.phoneNumber = self.numTextField.text;
            [digits authenticateWithViewController:nil configuration:configuration completion:^(DGTSession *newSession, NSError *error){
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CustomAlertController showCancelAlertControllerWithTitle:error.localizedDescription message:nil action:nil target:self];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        VerifyNumViewController *verifyNumVC = [[UIStoryboard storyboardWithName:@"LoginSignUp" bundle:nil]instantiateViewControllerWithIdentifier:@"verifyNumVC"];
                        [self.navigationController pushViewController:verifyNumVC animated:YES];
                    });
                }
            }];
            
        } failureHandler:^(NSString *errorString) {
            self.unvalidNum.hidden = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:self];
            });
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushToSelectCountry"]) {
        UINavigationController *nav = segue.destinationViewController;
        if ([nav isKindOfClass:[UINavigationController class]]) {
            if ([nav.topViewController isMemberOfClass:[CountrySelectTableViewController class]]) {
                CountrySelectTableViewController *topVC = (CountrySelectTableViewController *)nav.topViewController;
                topVC.delegate = self;
            }
        }
    }
}

#pragma mark - UITextfiled delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.unvalidNum.hidden = YES;
}

#pragma mark - Custom Delegate

- (void)didFinishedCountrySelected:(countryModel *)model {
    self.numPrefix.text = model.phoneCode;
    self.countryCode.text = model.countryCode;
    self.currentModel = model;
}

@end
