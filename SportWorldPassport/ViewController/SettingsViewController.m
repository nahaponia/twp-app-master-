//
//  SettingsViewController.m
//  SportWorldPassport
//
//  Created by star on 1/25/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "SettingsViewController.h"

#import "CategoryCell.h"
#import "CategoryInputCell.h"

#import "UIImage+Convenience.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CircleImageAddDelegate>
{
    IBOutlet UITableView *mTableView;
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtEmail;
    
    UIImage *image;
    NSMutableArray *categoryArray;
    PFUser *currentUser;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onChangeInputValue:(id)sender;

@end

bool isDelete = false;
UIButton *button;
@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imgAvatar.delegate = self;
    image = nil;
    
}

- (void) initialize {
    currentUser = [PFUser currentUser];
    categoryArray = currentUser[PARSE_USER_CATEGORIES];
    if (!categoryArray) {
        categoryArray = [[NSMutableArray alloc] init];
    }
    
    txtEmail.text = currentUser.email;
    txtFirstName.text = currentUser[PARSE_USER_FIRSTNAME];
    txtLastName.text = currentUser[PARSE_USER_LASTNAME];
    txtUsername.text = currentUser.username;
    
    if (image){
        [imgAvatar setImage:image];
    } else {
        [ParseUtils setParsePictureOf:imgAvatar file:currentUser[PARSE_USER_AVATAR] default:nil];
    }
    
    [mTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initialize];
}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChangeInputValue:(id)sender {
    [mTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:categoryArray.count+1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tapCircleImageView {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take A Photo", @"Select from Gallery", nil];
    
    [actionSheet showInView:self.view];
}


- (IBAction)onAddCategory:(id)sender {
    CategoryInputCell *cell = [mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:categoryArray.count inSection:0]];
    NSString *category = cell.txtTitle.text;
    if ([category isEqualToString:@""]) {
    } else if ([categoryArray containsObject:category]) {
        [CommonUtils showAlertView:TITLE_ERROR message:@"You have already have this sport." delegate:nil tag:TAG_ERROR];
    } else {
        cell.txtTitle.text = @"";
        [categoryArray addObject:category];
        [mTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:categoryArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self onSave:nil];
    }
}

- (IBAction)onSave:(id)sender {
    
    currentUser.username   = txtUsername.text;
    currentUser.email      = txtEmail.text;
    currentUser[PARSE_USER_FIRSTNAME] = txtFirstName.text;
    currentUser[PARSE_USER_LASTNAME] = txtLastName.text;
    currentUser[PARSE_USER_CATEGORIES] = categoryArray;
    
    if (image) {
        NSData *imageData = UIImagePNGRepresentation(image);
        currentUser[PARSE_USER_AVATAR] = [PFFile fileWithName:@"image.png" data:imageData];
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                
                [PFUser logInWithUsernameInBackground:txtUsername.text password:[AppConfig getStringValueForKey:LOGINED_USER_PASSWORD] block:^(PFUser *user, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (user) {
                        [AppConfig setStringValueForKey:LOGINED_USER_NAME value:txtUsername.text];
                        [AppConfig setStringValueForKey:LOGINED_USER_EMAIL value:txtEmail.text];
                        
                        if (!isDelete){
                            [CommonUtils showAlertView:TITLE_SUCCESS message:@"Your settings were saved successfully" delegate:nil tag:TAG_SUCCESS];
                        } else {
                            [CommonUtils showAlertView:TITLE_SUCCESS message:@"Your settings were changed successfully" delegate:nil tag:TAG_SUCCESS];
                            isDelete = !isDelete;
                        }
//                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        NSString *errorString = [error userInfo][@"error"];
                        [CommonUtils showAlertView:TITLE_ERROR message:errorString delegate:nil tag:TAG_ERROR];
                    }
                }];
                
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *errString = [error userInfo][@"error"];
            [CommonUtils showAlertView:TITLE_ERROR message:errString delegate:nil tag:TAG_ERROR];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger tag = [alertView tag];
    if (tag == TAG_DELETE && buttonIndex == 1) {
        NSIndexPath *indexPath = [mTableView indexPathForRowAtPoint:[[button superview] convertPoint:button.center toView:mTableView]];
        [categoryArray removeObjectAtIndex:indexPath.row];
        [self onSave:self];
        isDelete = true;
        [mTableView reloadData];
    }
}

// category delete
- (IBAction)onDeleteCategory:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure to delete?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:TAG_DELETE];
    button = (UIButton *)sender;
    [alertView show];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categoryArray.count + 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < categoryArray.count) {
        CategoryCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
        cCell.lblTitle.text = categoryArray[indexPath.row];
        cell = cCell;
    } else if (indexPath.row == categoryArray.count) {
        CategoryInputCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
        cell = cCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        UIButton *btnAdd = [cell.contentView viewWithTag:100];
        UIButton *btnSave = [cell.contentView viewWithTag:200];
        
        [btnAdd addTarget:self action:@selector(onAddCategory:) forControlEvents:UIControlEventTouchUpInside];
        [btnSave addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *checkString = [self checkInputValidation];
        if ([checkString isEqualToString:@""]) {
            [btnSave setEnabled:YES];
        } else {
            [btnSave setEnabled:NO];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= categoryArray.count) {
        return 44.0;
    }
    
    return 140.0;
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (NSString *)checkInputValidation {
    NSString *errMsg = @"";
    
    NSString *firstName = txtFirstName.text;
    NSString *lastName	= txtLastName.text;
    NSString *userName	= txtUsername.text;
    NSString *email     = txtEmail.text;
    
    if ([firstName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your first name.\n"];
    } else if ([lastName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your last name.\n"];
    } else if ([userName isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your user name.\n"];
    } else if ([email isEqualToString:@""]) {
        errMsg = [errMsg stringByAppendingString:@"Please enter your email.\n"];
    }
    
    return errMsg;
}

@end
