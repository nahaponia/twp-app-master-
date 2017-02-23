//
//  LoginViewController.m
//  SportWorldPassport
//
//  Created by star on 7/6/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "LoginViewController.h"

#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "TermsViewController.h"
#import "MainViewController.h"
#import "SignUpOneViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    BOOL m_isInitialized;
}

@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet NormalButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIImageView *iconEye;
@property (strong, nonatomic) IBOutlet UIButton *btnEye;

- (IBAction)onSignin:(id)sender;
- (IBAction)onSignUp:(id)sender;
- (IBAction)onExplain:(id)sender;
- (IBAction)onRecallPassword:(id)sender;
- (IBAction)onChangedTextField:(id)sender;

@end

@implementation LoginViewController

@synthesize txtEmail, txtPassword;
@synthesize btnLogin;
@synthesize iconEye;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [btnLogin setEnabled:NO];
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    txtEmail.text = [AppConfig getStringValueForKey:LOGINED_USER_EMAIL];
    
    if (TEST_MODE) {
        txtEmail.text = @"test@sample.com";
        txtPassword.text = @"123";
        [btnLogin setEnabled:YES];
        [iconEye setHidden:NO];
        _btnEye.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!m_isInitialized) {
        if (![txtEmail.text isEqualToString:@""] && ![[AppConfig getStringValueForKey:LOGINED_USER_PASSWORD] isEqualToString:@""]) {
//            [self onSignin:nil];
        }
        m_isInitialized = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignin:(id)sender {
//    [self performSegueWithIdentifier:@"gotoHomeSegue" sender:self];
    
    if (![txtEmail.text containsString:@"@"]){ // username log in
        [self onSigninWithUsername];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:txtEmail.text];
    [query whereKey:PARSE_FEED_BANNED notEqualTo:@"true"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (user) {
                    [AppConfig setStringValueForKey:LOGINED_USER_NAME value:username];
                    [AppConfig setStringValueForKey:LOGINED_USER_EMAIL value:txtEmail.text];
                    [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:txtPassword.text];
                    
                    PFInstallation *installObject = [PFInstallation currentInstallation];
                    installObject[PARSE_FIELD_USER] = user;
                    [installObject saveInBackground];
                    
                    MainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
                }
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *errorString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (void) onSigninWithUsername
{
    NSString *username = txtEmail.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser logInWithUsernameInBackground:username password:txtPassword.text block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (user) {
            [AppConfig setStringValueForKey:LOGINED_USER_NAME value:username];
            [AppConfig setStringValueForKey:LOGINED_USER_EMAIL value:user.email];
            [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:txtPassword.text];
            
            PFInstallation *installObject = [PFInstallation currentInstallation];
            installObject[PARSE_FIELD_USER] = user;
            [installObject saveInBackground];
            
            MainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            if ([errorString isEqualToString:@"No results matched the query."]){
                errorString = @"Invalid username/password";
            }
            [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (IBAction)onSignUp:(id)sender {
//    [self performSegueWithIdentifier:@"termsSegue" sender:self];
    SignUpOneViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpOneViewController"];
    [self.navigationController pushViewController:vc animated:YES];    
}

- (IBAction)onExplain:(id)sender {
    TermsViewController *vc = (TermsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
    vc.isWhat = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onRecallPassword:(id)sender {
    
    //before this, need to loggin
//    NSMutableDictionary *parmas = [[NSMutableDictionary alloc] init];
//    [parmas setValue:[PFUser currentUser].objectId forKey:@"userId"];
//    [parmas setValue:@"666" forKey:@"password"];
//    [PFCloud callFunctionInBackground:@"resetPassword" withParameters:parmas block:^(id object, NSError *err){
//        if (!err){
//        } else {
//            NSLog(@"failed");
//        }
//    }]; // Here we must test the email sending functions!   it seems not to working now!!!

     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Address"
                                                    message:@"Enter the email for your account:"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [alert textFieldAtIndex:0].placeholder = @"E-mail address";
    [alert setTag:TAG_PASSWORD_RESET];
    
    [alert show];
}

- (IBAction)onChangedTextField:(id)sender {
    NSString *errMsg = [self checkInputValidation];
    
    if ([errMsg isEqualToString:@""]) {
        [btnLogin setEnabled:YES];
    } else {
        [btnLogin setEnabled:NO];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}

- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    NSString *email = txtEmail.text;
    NSString *password = txtPassword.text;
    
    if ([email isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please input email"];
    }
    if ([password isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"%@ Please input password."];
        [iconEye setHidden:YES];
        [_btnEye setEnabled:NO];
    } else {
        [iconEye setHidden:NO];
        [_btnEye setEnabled:YES];
    }
    
    return errMsg;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_PASSWORD_RESET) {
        if (buttonIndex == 1) {
            
            UITextField *txtEmailField = [alertView textFieldAtIndex:0];
            NSString *email = txtEmailField.text;
            
            if (email.length > 1) {
                MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [hub setLabelText:@"Reset..."];
                [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (succeeded) {
                        NSString *msg = [NSString stringWithFormat:@"An email was successfully sent to %@ with reset instructions", email];
                        [CommonUtils showAlertView:TITLE_SUCCESS message:msg delegate:nil tag:TAG_SUCCESS];
                    } else {
                        NSString *errMsg = [error userInfo][@"error"];
                        [CommonUtils showAlertView:TITLE_ERROR message:errMsg delegate:nil tag:TAG_ERROR];
                    }
                }];
            }
        }
    }
    
}
- (IBAction)showPassword:(id)sender {
    if (txtPassword.secureTextEntry){
        txtPassword.font = [UIFont fontWithName:@"OpenSans" size:18];
    }
    [txtPassword setSecureTextEntry:!txtPassword.isSecureTextEntry];

}
@end
