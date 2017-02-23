//
//  SignUpOneViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "SignUpOneViewController.h"
#import "SignUpTwoViewController.h"

@interface SignUpOneViewController()
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIView *dividerView1;
    IBOutlet NormalButton *btnNext;
    IBOutlet UIView *errorView;
}

- (IBAction)onNextStep:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onChangedTextField:(id)sender ;
- (IBAction)onHideError:(id)sender;

@end


@implementation SignUpOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [btnNext setEnabled:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (IBAction)onChangedTextField:(id)sender {
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnNext setEnabled:YES];
    } else {
        [btnNext setEnabled:NO];
    }
}

- (IBAction)onHideError:(id)sender {
    [UIView animateWithDuration:TIME_ANIMATION_SHORT animations:^{
        [errorView setAlpha:0.0];
    } completion:^(BOOL finished) {
    }];
}

- (void)onShowError {
    [UIView animateWithDuration:TIME_ANIMATION_SHORT animations:^{
        [errorView setAlpha:1.0];
        [txtEmail setTextColor:COLOR_ORANGE];
        [dividerView1 setBackgroundColor:COLOR_ORANGE];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)onNextStep:(id)sender {
    if ([CommonUtils NSStringIsValidEmail:txtEmail.text]) {
//        [self performSegueWithIdentifier:@"gotoStep2" sender:self];
        SignUpTwoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpTwoViewController"];
        vc.email = txtEmail.text;
        vc.password = txtPassword.text;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self onShowError];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoStep2"]) {
        SignUpTwoViewController *vc = segue.destinationViewController;
        vc.email = txtEmail.text;
        vc.password = txtPassword.text;
    }
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    
    NSString *email = txtEmail.text;
    NSString *password	= txtPassword.text;
    
    if ([email isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your email address.\n"];
    } else if ([CommonUtils NSStringIsValidEmail:email]){
        [txtEmail setTextColor:COLOR_BLUE];
        [dividerView1 setBackgroundColor:COLOR_BLUE];
        [self onHideError:nil];
    }
    if ([password isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your password.\n"];
    }
    
    return errMsg;
}

@end
