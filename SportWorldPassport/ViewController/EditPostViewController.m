//
//  EditPostViewController.m
//  SportWorldPassport
//
//  Created by star on 1/26/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "EditPostViewController.h"

#import "HPGrowingTextView.h"

@interface EditPostViewController () <HPGrowingTextViewDelegate>
{
    IBOutlet UIImageView *imgPost;
    IBOutlet NormalButton *btnShare;
    IBOutlet UITextField *txtTitle;
    IBOutlet UITextField *txtDescription;
    IBOutlet UITextField *txtHashTags;
    IBOutlet NSLayoutConstraint *descriptHeight;
    IBOutlet NSLayoutConstraint *inputviewHeight;
    IBOutlet UIView *containerView;
    IBOutlet UITableView *tableView;
    IBOutlet UITextField *txtLocation;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onChangedTextField:(id)sender;

@end

@implementation EditPostViewController

@synthesize postObject;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    txtDescription.minNumberOfLines = 1;
//    txtDescription.maxNumberOfLines = 10;
    txtDescription.textColor = COLOR_BLUE;
    txtDescription.placeholder = @"Description";
//    txtDescription.placeholderColor = [UIColor colorWithRed:167/255.0 green:172/255.0 blue:183/255.0 alpha:1.0];
//    txtDescription.delegate = self;
    txtDescription.font = [UIFont systemFontOfSize:14.0f];
//    txtDescription.contentInset = UIEdgeInsetsMake(0, -5, -2, -5);
//    txtDescription.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    txtDescription.backgroundColor = [UIColor clearColor];
    
    [ParseUtils setParsePictureOf:imgPost file:postObject[PARSE_FEED_SMALL_PHOTO] default:nil];
    txtTitle.text = postObject[PARSE_FEED_TITLE];
    txtHashTags.text = postObject[PARSE_FEED_TAGS];
    txtLocation.text = postObject[PARSE_FEED_LOCATION];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    txtDescription.text = postObject[PARSE_FEED_DESCRIPT];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onShare:(id)sender {

    postObject[PARSE_FEED_TITLE]        = txtTitle.text;
    postObject[PARSE_FEED_DESCRIPT]     = txtDescription.text;
    postObject[PARSE_FEED_TAGS]         = txtHashTags.text;
    postObject[PARSE_FEED_LOCATION]      = txtLocation.text;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            if (self.delegate) {
                [self.delegate didChangedPost:postObject];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (IBAction)onChangedTextField:(id)sender {
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnShare setEnabled:YES];
    } else {
//        [btnShare setEnabled:NO];
    }
}

#pragma GrowingText view delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    NSLog(@"text view height changed: %.1f", height);
    
    descriptHeight.constant = height;
    inputviewHeight.constant = 94 + height;
    
    CGRect frame = containerView.frame;
    frame.size.height = SCREEN_WIDTH * 41 / 80 + inputviewHeight.constant + 130;
    [containerView setFrame:frame];
    [containerView setNeedsLayout];
    [self.view setNeedsLayout];
    
    tableView.contentSize = containerView.frame.size;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnShare setEnabled:YES];
    } else {
        [btnShare setEnabled:NO];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}

- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    NSString *title = txtTitle.text;
    NSString *description = txtDescription.text;
    NSString *tags = txtHashTags.text;
    
    if ([title isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please input email"];
    } else if ([description isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"%@ Please input description."];
    } else if ([tags isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"%@ Please input tags."];
    }
    
    return errMsg;
    
}
@end
