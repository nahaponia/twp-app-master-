//
//  InviteViewController.m
//  SportWorldPassport
//
//  Created by star on 1/25/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "InviteViewController.h"
#import "CategoryCell.h"
#import "CategoryInputCell.h"
#import "ToastView.h"
#import <MessageUI/MessageUI.h>

@interface InviteViewController () <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet UITableView *mTableView;
    NSMutableArray *emailArray;
    NSMutableArray *phoneArray;
    
    int invalidEmails;
}

- (IBAction)onBack:(id)sender;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    emailArray = [[NSMutableArray alloc] init];
    phoneArray = [[NSMutableArray alloc] init];
    
    invalidEmails = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddEmail:(id)sender {
    CategoryInputCell *cell = [mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:emailArray.count inSection:0]];
    BOOL is = [cell isKindOfClass:[CategoryInputCell class]];
    if (!is){
        return;
    }
    NSString *email = cell.txtTitle.text;
    if (![CommonUtils NSStringIsValidEmail:email]){
        invalidEmails ++;
    }
    if ([email isEqualToString:@""]) {
    } else if ([emailArray containsObject:email]) {
        [CommonUtils showAlertView:TITLE_ERROR message:@"You already have this email." delegate:nil tag:TAG_ERROR];
    } else {
        cell.txtTitle.text = @"";
        [emailArray addObject:email];
        [mTableView reloadData];
    }
}

- (IBAction)onInviteByEmail:(id)sender {
    
    
    NSString *msg = @"Please install https://itunes.apple.com/us/app/travelworldpassport/id1174939455?mt=8  TravelWorldPassport";
    
    if (invalidEmails == 1){
        [ToastView showToast:@" One email is incorrect " durationTime:1];
        if (emailArray.count == 1){
            return;
        }
    } else if (invalidEmails == emailArray.count){
        [ToastView showToast:@" All emails are incorrect " durationTime:1];
        return;
    } else if (invalidEmails > 1){
        [ToastView showToast:[NSString stringWithFormat:@" %d emails are incorrect ", invalidEmails] durationTime:1];
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[PFUser currentUser].email forKey:@"fromEmail"];
    [dic setValue:msg forKey:@"text"];
    [dic setValue:@"Invitation to TravelWorldPassport" forKey:@"subject"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < emailArray.count; i++) {
        [array addObject:@{@"email" : emailArray[i], @"type":@"to"}];
        [dic setValue:emailArray[i] forKey:@"toEmail"];
        
        [PFCloud callFunctionInBackground:@"mailSendwithText" withParameters:dic block:^(NSString* result, NSError *error){
            if (error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"error happened in Mail sending: %@", error.description);
            } else {
                if (i == emailArray.count -1){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [CommonUtils showAlertView:TITLE_SUCCESS message:@"Mail sent successfully." delegate:self tag:TAG_SUCCESS];
                }
                NSLog(@"Sending mail successfully");
            }
        }];
    }
}

- (IBAction)onAddPhoneNumber:(id)sender {
    CategoryInputCell *cell = [mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:phoneArray.count+1 inSection:1]];
    if (![cell isKindOfClass:[CategoryInputCell class]]){
        return;
    }
    NSString *phone = cell.txtTitle.text;
    if ([phone isEqualToString:@""]) {
    } else if ([phoneArray containsObject:phone]) {
        [CommonUtils showAlertView:TITLE_ERROR message:@"You already have this phone number." delegate:nil tag:TAG_ERROR];
    } else {
        cell.txtTitle.text = @"";
        [phoneArray addObject:phone];
        [mTableView reloadData];
    }
}

- (IBAction)onInviteByPhoneNumber:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        NSString *msg = @" Invite to TravelWorldPassport Please install https://itunes.apple.com/us/app/travelworldpassport/id1174939455?mt=8  TravelWorldPassport";
        controller.body = msg;
        controller.recipients = phoneArray;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    /*
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:phoneArray];
        [composeViewController setSubject:@"Invite to Sport World Passport"];
        NSString *messageString = @"";
        [composeViewController setMessageBody:messageString isHTML:NO];
        [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
    }
     */
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Message cancelled");
    } else if (result == MessageComposeResultSent) {
//        [CommonUtils showAlertView:TITLE_SUCCESS message:@"SMS sent successfully." delegate:self tag:TAG_SUCCESS];
        NSLog(@"Message sent");
    } else {
        NSLog(@"Message failed");
    }
}

#pragma mark - MFMailCompose Viewcontroller Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            NSLog(@"mail sent");
        } else if (result == MFMailComposeResultFailed){
            NSLog(@"mail failed");
        } else if (result == MFMailComposeResultSaved){
            NSLog(@"mail saved");
        }
        NSLog(@"mail sent");
    }];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return emailArray.count + 2;
    } else {
        return phoneArray.count + 3;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row < emailArray.count) {
            CategoryCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
            cCell.lblTitle.text = emailArray[indexPath.row];
            cell = cCell;
        } else if (indexPath.row == emailArray.count) {
            CategoryInputCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"emailInputCell"];
            cell = cCell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell1"];
            UIButton *btnAdd = [cell.contentView viewWithTag:100];
            UIButton *btnInterview = [cell.contentView viewWithTag:200];
            if (emailArray.count > 0) {
                [btnInterview setEnabled:YES];
            } else {
                [btnInterview setEnabled:NO];
            }
            
            [btnAdd addTarget:self action:@selector(onAddEmail:) forControlEvents:UIControlEventTouchUpInside];
            [btnInterview addTarget:self action:@selector(onInviteByEmail:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        } else if (indexPath.row <= phoneArray.count) {
            CategoryCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
            cCell.lblTitle.text = phoneArray[indexPath.row-1];
            cell = cCell;
        } else if (indexPath.row == phoneArray.count + 1) {
            CategoryInputCell *cCell = [tableView dequeueReusableCellWithIdentifier:@"phoneInputCell"];
            cell = cCell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell2"];
            UIButton *btnAdd = [cell.contentView viewWithTag:100];
            UIButton *btnInterview = [cell.contentView viewWithTag:200];
            if (phoneArray.count > 0) {
                [btnInterview setEnabled:YES];
            } else {
                [btnInterview setEnabled:NO];
            }
            
            [btnAdd addTarget:self action:@selector(onAddPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
            [btnInterview addTarget:self action:@selector(onInviteByPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row <= emailArray.count) {
            return 45;
        } else {
            return 115;
        }
    } else {
        if (indexPath.row == 0) {
            return 50;
        } else if (indexPath.row <= phoneArray.count + 1) {
            return 45;
        } else {
            return 115;
        }
    }
    
    return 140.0;
}

#pragma mark - TextView data source delegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"E-mail address"]){
        NSLog(@"Add Email");
        [self onAddEmail:nil];
    } else if ([textField.placeholder isEqualToString:@"Phone number"]){
        NSLog(@"Add Phone");
        [self onAddPhoneNumber:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger tag = [alertView tag];
    if (tag == TAG_SUCCESS) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
