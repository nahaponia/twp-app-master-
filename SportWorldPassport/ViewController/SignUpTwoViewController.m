//
//  SignUpTwoViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "SignUpTwoViewController.h"
#import "UIImage+Convenience.h"
#import "TermsViewController.h"

@interface SignUpTwoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UITableView *mTableView;
    IBOutlet NormalButton *btnSignup;
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtUsername;
    
    IBOutlet UIButton *btnCheck;
    IBOutlet UILabel *errorMsg;
    UIImage *image;
    UIImage *icon_check;
    UIImage *icon_uncheck;
    IBOutlet UIView *errorView;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onAddPhoto:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onChangeInputValue:(id)sender;

@end

bool isChecked = false;
@implementation SignUpTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    image = nil;
    icon_check = [UIImage imageNamed:@"ic_check"];
    icon_uncheck = [UIImage imageNamed:@"ic_uncheck"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take A Photo", @"Select from Gallery", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)onPressTOS:(id)sender {
    TermsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
//    [self.navigationController pushViewController:vc animated:NO];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)onPressCheck:(id)sender {
    isChecked = !isChecked;
    if (isChecked){
        [btnCheck setBackgroundImage:icon_check forState:UIControlStateNormal];
    } else {
        [btnCheck setBackgroundImage:icon_uncheck forState:UIControlStateNormal];
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
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)onNext:(id)sender {
    
//    if (!isChecked){
//        [self onShowError];
//        return;
//    }
    
    NSString *errMsg = [self checkInputValidation];
    if ([errMsg length]>0){
        [errorMsg setText:errMsg];
        [self onShowError];
        return;
    }
    
    PFUser *user = [PFUser user];
    
    user.username   = txtUsername.text;
    user.email      = self.email;
    user.password   = self.password;
    user[PARSE_USER_FIRSTNAME] = txtFirstName.text;
    user[PARSE_USER_LASTNAME] = txtLastName.text;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    user[PARSE_USER_AVATAR] = [PFFile fileWithName:@"image.png" data:imageData];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            [AppConfig setStringValueForKey:LOGINED_USER_NAME value:user.username];
            [AppConfig setStringValueForKey:LOGINED_USER_EMAIL value:user.email];
            [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:user.password];
            
            PFInstallation *installObject = [PFInstallation currentInstallation];
            installObject[PARSE_FIELD_USER] = user;
            [installObject saveInBackground];
            
            [self performSegueWithIdentifier:@"gotoHomeSegue" sender:self];
        } else {
            NSString *errString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (IBAction)onChangeInputValue:(id)sender {
//    [self checkInputValidation];
}



#pragma actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2 ) {
        UIImagePickerController *pickercontroller = [[UIImagePickerController alloc] init];
        [pickercontroller setDelegate:self];
        [pickercontroller setAllowsEditing:YES];
        
        if (buttonIndex == 0) { // take photo
            [pickercontroller setSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (buttonIndex == 1) { // select from library
            [pickercontroller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:pickercontroller animated:YES completion:nil];
        }];
    }
}

#pragma image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info valueForKey:UIImagePickerControllerEditedImage];
    image = [image getCroppedImage:IMAGE_SIZE_SMALL height:IMAGE_SIZE_SMALL];
    
    [imgAvatar setImage:image];
    
    [self checkInputValidation];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
//
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    
    NSString *firstName = txtFirstName.text;
    NSString *lastName	= txtLastName.text;
    NSString *userName	= txtUsername.text;
    
    if ([firstName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your first name.\n"];
        return errMsg;
    } else if ([lastName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your last name.\n"];
        return errMsg;
    } else if ([userName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your user name.\n"];
        return errMsg;
    } else if (!image) {
        errMsg = [errMsg stringByAppendingString:@"Please set your image.\n"];
        return errMsg;
    } else if (!isChecked) {
        errMsg = [errMsg stringByAppendingString:@"You should accept Terms of Service first"];
        return errMsg;
    }
    
//    if (errMsg.length == 0) {
//        [btnSignup setEnabled:YES];
//    } else {
//       [btnSignup setEnabled:NO];
//    }
    
    return errMsg;
}


@end
