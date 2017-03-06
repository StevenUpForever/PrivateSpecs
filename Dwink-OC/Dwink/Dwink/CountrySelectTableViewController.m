//
//  CountrySelectTableViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 12/7/16.
//  Copyright © 2016 Dwink. All rights reserved.
//

#import "CountrySelectTableViewController.h"
#import "CountrySelectTableViewCell.h"
#import "SignUpViewController.h"

@interface CountrySelectTableViewController ()

@property (nonatomic) NSMutableArray<countryModel *> *countryArray;

@end

@implementation CountrySelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    
    self.countryArray = [[NSMutableArray alloc]init];
    
    [[[NSOperationQueue alloc]init] addOperationWithBlock:^{
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"CountriesWithPhoneCodes" ofType:@"plist"];
        NSArray *tempArray = [[NSArray alloc]initWithContentsOfFile:filePath];
        if ([tempArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in tempArray) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    NSString *countryCode = dict[@"code"];
                    NSString *countryName = dict[@"name"];
                    NSString *phoneCode = [NSString stringWithFormat:@"+%@", dict[@"phone_code"]];
                    countryModel *model = [[countryModel alloc]initWithName:countryName phoneCode:phoneCode countryCode:countryCode];
                    [self.countryArray addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CountrySelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell loadData:self.countryArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    countryModel *currentModel = self.countryArray[indexPath.row];
    [self.delegate didFinishedCountrySelected:currentModel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Selector

- (void)cancelButtonTapped: (UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
