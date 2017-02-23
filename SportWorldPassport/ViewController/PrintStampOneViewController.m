//
//  PrintStampOneViewController.m
//  SportWorldPassport
//
//  Created by developer on 12/07/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <Stripe/Stripe.h>

#import "PrintStampOneViewController.h"
#import "PrintStampTwoViewController.h"
#import "DeliveryAndBillingModel.h"

@interface PrintStampOneViewController () <UITextFieldDelegate>
{
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtCountry;
    IBOutlet UITextField *txtStreet;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtPostcode;
    IBOutlet UITextField *txtPhoneNumber;
    
    IBOutlet UITextField *txtCardNumber;
    IBOutlet UITextField *txtExpireDate;
    IBOutlet UITextField *txtCVV;
    
    IBOutlet UIButton *btnNext;
    
    STPCardParams *internalCardParams;
}
@end

@implementation PrintStampOneViewController

@synthesize stampArray;

#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

- (void)viewDidLoad{
    [super viewDidLoad];
    
    internalCardParams = [STPCardParams new];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           flexibleSpaceLeft,
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    txtPhoneNumber.inputAccessoryView = numberToolbar;
    txtPhoneNumber.keyboardType = UIKeyboardTypePhonePad;
    txtFirstName.keyboardType = UIKeyboardTypeAlphabet;
    txtLastName.keyboardType = UIKeyboardTypeAlphabet;
    txtCountry.keyboardType = UIKeyboardTypeAlphabet;
    txtCity.keyboardType = UIKeyboardTypeAlphabet;
    txtPostcode.inputAccessoryView = numberToolbar;
    txtPostcode.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    [txtCardNumber addTarget:self
                        action:@selector(reformatAsCardNumber:)
            forControlEvents:UIControlEventEditingChanged];
    txtCardNumber.inputAccessoryView = numberToolbar;
    txtCardNumber.keyboardType = UIKeyboardTypeNumberPad;
    txtExpireDate.inputAccessoryView = numberToolbar;
    txtExpireDate.keyboardType = UIKeyboardTypeNumberPad;
    txtCVV.inputAccessoryView = numberToolbar;
    txtCVV.keyboardType = UIKeyboardTypeNumberPad;

    /*
    txtFirstName.text = @"Michael";
    txtLastName.text = @"Johnson";
    txtCountry.text = @"Australia";
    txtStreet.text = @"7070 Photinia Ave";
    txtCity.text = @"Sydney";
    txtPostcode.text = @"2005";
    txtPhoneNumber.text = @"(883)-847-7029";
    
    txtCardNumber.text = @"4242 4242 4242 4242";
    txtExpireDate.text = @"12/17";
    txtCVV.text = @"123";
     */
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DeliveryAndBillingModel *model = [AppConfig getDeliveryModel];
    txtFirstName.text = model.firstName;
    txtLastName.text = model.lastName;
    txtCountry.text = model.country;
    txtStreet.text = model.street;
    txtCity.text = model.city;
    txtPostcode.text = model.postcode;
    txtPhoneNumber.text = model.phoneNumber;
}

-(void)doneWithNumberPad{
    [self resetFields];
}

- (void)resetFields{
    [txtFirstName resignFirstResponder];
    [txtLastName resignFirstResponder];
    [txtCountry resignFirstResponder];
    [txtStreet resignFirstResponder];
    [txtCity resignFirstResponder];
    [txtPostcode resignFirstResponder];
    [txtPhoneNumber resignFirstResponder];
    [txtCardNumber resignFirstResponder];
    [txtExpireDate resignFirstResponder];
    [txtCVV resignFirstResponder];
}

//IBActions
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (STPCardParams *)cardParams {
    internalCardParams.number = [txtCardNumber.text stringByReplacingOccurrencesOfString:@" "
                                                                                   withString:@""];
    NSArray *dateArray = [txtExpireDate.text componentsSeparatedByString:@"/"];
    internalCardParams.expMonth = [[dateArray objectAtIndex:0] integerValue];
    internalCardParams.expYear = [[dateArray objectAtIndex:1] integerValue];
    internalCardParams.cvc = txtCVV.text;
    return internalCardParams;
}

- (DeliveryAndBillingModel *)getDeliveryAndBillingModel{
    DeliveryAndBillingModel* model = [[DeliveryAndBillingModel alloc] init];
    
    model.firstName = txtFirstName.text;
    model.lastName = txtLastName.text;
    model.country = txtCountry.text;
    model.street = txtStreet.text;
    model.city = txtCity.text;
    model.postcode = txtPostcode.text;
    model.phoneNumber = txtPhoneNumber.text;
    
    model.cardNumber = txtCardNumber.text;
    model.expireDate = txtExpireDate.text;
    model.cvv = txtCVV.text;
    
    return model;
}

- (BOOL) isAvailableParams{
    NSMutableString *errors = [NSMutableString string];
    if ([txtFirstName.text length] == 0){
        [errors appendString:@"Please enter your First Name. \n"];
    }
    if ([txtLastName.text length] == 0){
        [errors appendString:@"Please enter your Last Name. \n"];
    }
    if ([txtCountry.text length] == 0){
        [errors appendString:@"Please enter your Country. \n"];
    }
    if ([txtStreet.text length] == 0){
        [errors appendString:@"Please enter your Street. \n"];
    }
    if ([txtCity.text length] == 0){
        [errors appendString:@"Please enter your City. \n"];
    }
    if ([txtPostcode.text length] == 0){
        [errors appendString:@"Please enter your PostCode. \n"];
    }
    if ([txtPhoneNumber.text length] == 0){
        [errors appendString:@"Please enter your Phone Number. \n"];
    }
    if ([txtCardNumber.text length] == 0){
        [errors appendString:@"Please enter your Card Number. \n"];
    }
    if ([txtExpireDate.text length] == 0){
        [errors appendString:@"Please enter your Expire Date. \n"];
    }
    if ([txtCVV.text length] == 0){
        [errors appendString:@"Please enter your CVV. \n"];
    }
    if([errors length]) {
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
                                                            message:[errors substringWithRange:NSMakeRange(0, [errors length]-1)]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:nil,nil];
        [errorView show];
        return false;
    }
    return true;
}

- (IBAction)onNextPressed:(id)sender {
    if (![self isAvailableParams]){
        return;
    }
    
    // save delivery information
    DeliveryAndBillingModel *model = [self getDeliveryAndBillingModel];
    [AppConfig setDeliveryModel:model];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[STPAPIClient sharedClient] createTokenWithCard:[self cardParams]
                                          completion:^(STPToken *token, NSError *error) {
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  if (error) {
                                                      [CommonUtils showAlertView:TITLE_ERROR message:[error localizedDescription] delegate:nil tag:TAG_ERROR];
                                                      return;
                                                  }
                                                  PrintStampTwoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PrintStampTwoViewController"];
                                                  vc.stripeToken = token;
                                                  vc.model = model;
                                                  vc.stampArray = stampArray;
                                                  [self.navigationController pushViewController:vc animated:YES];
                                              });
                                          }];
}

- (IBAction)onChangeInputValue:(id)sender {
    [self validateNext];
}

-(void)validateNext{
    if([txtCardNumber.text length] > 0 && [txtExpireDate.text length] > 0 && [txtCVV.text length] > 0){
        btnNext.enabled = YES;
    }else{
        btnNext.enabled = NO;
    }
}

-(NSString*)formatNumber:(NSString*)mobileNumber{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}

#pragma mark - TextField delegate
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField.text.length >= 100 && range.length == 0 && textField.tag != 107)
        return NO;
    else{
        if(textField.tag == 101 || textField.tag == 102 || textField.tag == 103){
            NSCharacterSet *unacceptedInput = nil;
            unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
            return ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] <= 1);
        }else if(textField.tag == 106){ //zip field
            return (newLength > 8) ? NO : YES;
        }else if(textField.tag == 107){ // phone number
            
            int length = [self getLength:txtPhoneNumber.text];
            if (length > 0){
                NSString *num = txtPhoneNumber.text;
                num = [num stringByReplacingOccurrencesOfString:@"+" withString:@""];
                txtPhoneNumber.text = [NSString stringWithFormat:@"+%@", num];
            }
//            if(length == 10)
//            {
//                if(range.length == 0)
//                    return NO;
//            }
//            
//            if(length == 1)
//            {
//                NSString *num = [self formatNumber:txtPhoneNumber.text];
//                txtPhoneNumber.text = [NSString stringWithFormat:@"(%@",num];
//                
//            }
//            else if(length == 3)
//            {
//                NSString *num = [self formatNumber:txtPhoneNumber.text];
//                txtPhoneNumber.text = [NSString stringWithFormat:@"(%@)-",num];
//                if(range.length > 0)
//                    txtPhoneNumber.text = [NSString stringWithFormat:@"(%@",[num substringToIndex:3]];
//            }
//            else if(length == 6)
//            {
//                NSString *num = [self formatNumber:txtPhoneNumber.text];
//                txtPhoneNumber.text = [NSString stringWithFormat:@"(%@)-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
//                if(range.length > 0)
//                    txtPhoneNumber.text = [NSString stringWithFormat:@"(%@)-%@",[num substringToIndex:3],[num substringFromIndex:3]];
//            }
        } else if(textField.tag == 108){
            return ((textField.text.length >= 19 && range.length == 0)) ? NO : YES;
        } else if(textField.tag == 109){
             if(textField.text.length >= 5 && range.length == 0){
                 return NO;
             }else{
                 const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
                 int isBackSpace = strcmp(_char, "\b");
                 
                 if (isBackSpace == -8) {
                     // is backspace
                     
                 }else if(textField.text.length == 2){
                     textField.text = [NSString stringWithFormat:@"%@/", textField.text];
                 }
                 return YES;
             }
        }else if(textField.tag == 110){ //CVV field
            return (newLength > 3) ? NO : YES;
        }
    }
    
    return YES;
}

-(void)reformatAsCardNumber:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > 16) {
        // If the user is trying to enter more than 19 digits, we prevent
        // their change, leaving the text field in  its previous state.
        // While 16 digits is usual, credit card numbers have a hard
        // maximum of 19 digits defined by ISO standard 7812-1 in section
        // 3.8 and elsewhere. Applying this hard maximum here rather than
        // a maximum of 16 ensures that users with unusual card numbers
        // will still be able to enter their card number even if the
        // resultant formatting is odd.
        //        [textField setText:previousTextFieldContent];
        //        textField.selectedTextRange = previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
}

- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

@end
