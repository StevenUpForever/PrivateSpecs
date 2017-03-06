//
//  addTweetViewController.m
//  Dwink
//
//  Created by Chengzhi Jia on 16/3/4.
//  Copyright © 2016年 Dwink. All rights reserved.
//

#import "CreatePostViewController.h"
#import "SocialAPI+UnpagedAPICategory.h"
#import "ImageAPI.h"
#import "CustomPostImageView.h"
#import "UIKitCategories.h"
#import "ImageManager.h"
#import "DetailImageViewController.h"
#import "DetailImageNavController.h"
#import "ImagePreviewViewController.h"
#import "AppDelegate.h"

@interface CreatePostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, DetailImageVCDelegate, imagePreviewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *postTextField;

@property (strong, nonatomic) IBOutletCollection(CustomPostImageView) NSArray *postImageViewCollection;

@property (nonatomic) NSMutableArray<UIImage *> *currentImageArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Post";
    
    self.currentImageArray = [[NSMutableArray alloc]init];
    
    //Add left and right bar button item
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
    
    //Initial Button array
    
    [self.postImageViewCollection enumerateObjectsUsingBlock:^(CustomPostImageView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.postImageViewCollection indexOfObject:obj] != 0) {
            obj.hidden = YES;
        }
    }];
    
    //Set textView placeHolder Initial
    
    self.postTextField.text = @"Write Something...";
    self.postTextField.textColor = [UIColor DwinkGrey];
    self.postTextField.delegate = self;
    
    self.scrollView.delegate = self;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditing)]];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButton {
    
    [self.postTextField resignFirstResponder];
    
    NSString *postString;
    if (self.postTextField.textColor == [UIColor blackColor]) {
        postString = self.postTextField.text;
    }
    
    [UserInfoNotification notificationCenter].needBeginUploadingHint = YES;
    
    [ImageAPI uploadAllPostImages:self.currentImageArray successHandler:^(NSArray *imageStrArray) {
        
        [ImageManager clearAllPostImageCache];
        
        [SocialAPI createNewPostWithText:postString imageStrArray:imageStrArray video:@"" successHandler:^{
            
            [[UserInfoNotification notificationCenter] beginNotifyRefreshUI];
            
        } failureHandler:^(NSString *errorString) {
            [[UserInfoNotification notificationCenter] failedRefreshUI];
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:appDelegate.tabBarController];
            });
        }];
        
    } failureHandler:^(NSString *errorString) {
        [[UserInfoNotification notificationCenter] failedRefreshUI];
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [CustomAlertController showCancelAlertControllerWithTitle:errorString message:nil action:nil target:appDelegate.tabBarController];
        });
    }];
    
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)imageViewClicked:(UITapGestureRecognizer *)sender {
    CustomPostImageView *postImageView = (CustomPostImageView *)sender.view;
    if (postImageView.imageHasShown) {
        DetailImageViewController *detailImageVC = [[DetailImageViewController alloc]initWithImageArray:self.currentImageArray andCurrentIndex:sender.view.tag delegate:self];
        DetailImageNavController *navCon = [[DetailImageNavController alloc]initWithRootController:detailImageVC mode:detailImageModeSelf];
        [self presentViewController:navCon animated:YES completion:nil];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        [CustomAlertController showImagePickerControllerWithImagePicker:imagePicker target:self completionHandler:^{
            imagePicker.view.tag = sender.view.tag;
        }];
    }
}

#pragma mark - delegate methods

//ImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *changedImage = info[UIImagePickerControllerOriginalImage];
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        ImagePreviewViewController *previewVC = [[ImagePreviewViewController alloc]init];
        previewVC.delegate = self;
        previewVC.image = changedImage;
        previewVC.imagePicker = picker;
        [picker pushViewController:previewVC animated:YES];
    } else {
        [self didSaveImageButtonClicked:changedImage imagePicker:picker];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//TextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.textColor isEqual:[UIColor DwinkGrey]]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Write Something...";
        textView.textColor = [UIColor DwinkGrey];
    }
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    CGFloat fixedWidth = textView.frame.size.width;
//    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//    if (newSize.height > 100.0) {
//        self.textViewHeight.constant = newSize.height + 10;
//        [self.contentView layoutIfNeeded];
//    }
//    return YES;
//}
//
//- (void)keyboardWasShown:(NSNotification*)aNotification
//{
//    NSDictionary* info = aNotification.userInfo;
//    CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    
//    [UIView animateWithDuration:UIKeyboardAnimationDurationUserInfoKey.doubleValue animations:^{
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, kbSize.height + 10, 0);
//        self.scrollView.contentInset = contentInsets;
//        self.postTextField.contentInset = contentInsets;
//        self.scrollView.scrollIndicatorInsets = contentInsets;
//    }];
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your app might not need or want this behavior.
//    //    CGRect aRect = self.view.frame;
//    //    aRect.size.height -= kbSize.height;
//    //    if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
//    //        [self.scrollView scrollRectToVisible: self.activeTextField.frame animated:YES];
//    //    }
//}
//
//// Called when the UIKeyboardWillHideNotification is sent
//
//- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//    self.scrollView.scrollsToTop = YES;
//}
//Custom delegate

- (void)didClickDeleteButtonForImageAtIndex:(NSUInteger)index {
    [self.currentImageArray removeObjectAtIndex:index];
    for (int index = 0; index < self.postImageViewCollection.count; index++) {
        CustomPostImageView *currentImageView = self.postImageViewCollection[index];
        if (index < self.currentImageArray.count) {
            [currentImageView loadImageWithCroppedImage:self.currentImageArray[index]];
        } else {
            currentImageView.image = [UIImage imageNamed:@"defaultImage155"];
            currentImageView.fullSizeImage = nil;
            currentImageView.imageHasShown = NO;
            if (index > self.currentImageArray.count) {
                currentImageView.hidden = YES;
            }
        }
    }
}

- (void)didSaveImageButtonClicked:(UIImage *)image imagePicker: (UIImagePickerController *)picker {
    CustomPostImageView *imageView = (self.postImageViewCollection)[picker.view.tag];
    [imageView loadImageWithCroppedImage:image];
//    imageView.image = image;
    imageView.fullSizeImage = image;
    imageView.imageHasShown = YES;

    [self.currentImageArray addObject:image];

    if (picker.view.tag < self.postImageViewCollection.count - 1) {
        CustomPostImageView *nextImageView = (self.postImageViewCollection)[picker.view.tag + 1];
        nextImageView.hidden = NO;
    }
}

#pragma mark - Custom Selectors

- (void)endEditing {
    [self.view endEditing:YES];
}

@end
