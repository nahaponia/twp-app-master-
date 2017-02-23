//
//  CommonUtils.m
//  SportsE
//
//  Created by star on 6/22/15.
//  Copyright (c) 2015 star. All rights reserved.
//

#import "CommonUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Twitter/Twitter.h>
//#import <AccountKit/AccountKit.h>
#import <Accounts/Accounts.h>
#import <Fabric/Fabric.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static CustomIOS7AlertView *customAlertView;

@implementation CommonUtils

+ (void)showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles: nil];

    [alert setTag:tag];
    [alert show];
}

+ (void)makeCallWithNumber:(NSString *)number {
//    NSString *phoneNumber = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    
//    NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
    NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:number]];
    
//    if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
//        [UIApplication.sharedApplication openURL:phoneUrl];
//    } else
    if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
        [UIApplication.sharedApplication openURL:phoneFallbackUrl];
    } else {
        [CommonUtils showAlertView:APP_NAME message:@"You can't call in this device" delegate:nil tag:TAG_ERROR];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (CustomIOS7AlertView *) showCustomAlertView:(UIView *) parentView view:(UIView *) view buttonTitleList:(NSMutableArray *)buttonTitleList completionBlock: (void (^)(int buttonIndex))completionBlock
{
    if (customAlertView == nil) {
        customAlertView = [[CustomIOS7AlertView alloc] init];
    } else {
        for (UIView *view in customAlertView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    // Add some custom content to the alert view
    [customAlertView setContainerView:view];
    
    // Modify the parameters
    [customAlertView setButtonTitles:buttonTitleList];
    
    // You may use a Block, rather than a delegate.
    [customAlertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %ld.", buttonIndex, (long)[alertView tag]);
        [alertView close];
        completionBlock (buttonIndex);
    }];
    
    customAlertView.parentView = parentView;
    [customAlertView show]; 
    [customAlertView setUseMotionEffects:true]; 
    
    return customAlertView; 
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

+ (UIImage *)createQRCodeImageForString:(NSString *)qrString imageWidth:(float)width imageHeight:(float)height {
    CIImage *qrcodeImage = [self createQRForString:qrString];
    
    float scaleX = width / qrcodeImage.extent.size.width;
    float scaleY = height / qrcodeImage.extent.size.height;
    
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:(CGAffineTransformMakeScale(scaleX, scaleY))];
    
    return [UIImage imageWithCIImage:transformedImage];
}

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *) colorWithHexString: (NSString *) hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    
    NSLog(@"colorString :%@",colorString);
    CGFloat alpha, red, blue, green;
    
    // #RGB
    alpha = 1.0f;
    red   = [self colorComponentFrom: colorString start: 0 length: 2];
    green = [self colorComponentFrom: colorString start: 2 length: 2];
    blue  = [self colorComponentFrom: colorString start: 4 length: 2];
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (void) sendEmailToAdminsWithText:(NSString *)text
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"hi@travelworldpassport.com" forKey:@"toEmail"];
    [dic setValue:[PFUser currentUser].email forKey:@"fromEmail"];
    [dic setValue:text forKey:@"text"];
    [dic setValue:@"Inappropriate Report" forKey:@"subject"];
    [PFCloud callFunctionInBackground:@"mailSendwithText" withParameters:dic block:^(NSString* result, NSError *error){
        if (error){
            NSLog(@"error");
        }
    }];
}

+ (void) shareImagetoFacebook:(UIImage *)image sender:(id)delegate withView:(UIView *)view andDescription:(NSString *)desc
{
    if (view){
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    
    if (![FBSDKAccessToken currentAccessToken]){ // not log in to Facebook
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:delegate handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (view){
                [MBProgressHUD hideHUDForView:view animated:YES];
            }
            
            if (error){
                NSLog(@"%@@", error.description);
                [self showAlertView:@"Facebook Login Failed!" message:error.description delegate:self tag:TAG_ERROR];
            } else
                if (result.isCancelled){
                    [self showAlertView:@"" message:@"Facebook Login Cancelled!" delegate:self tag:TAG_ERROR];
                } else {
                    NSLog(@"Facebook login success!");
                    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
                    photo.image = image;
                    photo.userGenerated = YES;
                    photo.caption = desc;
                    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                    content.photos = [ NSArray arrayWithObject:photo ];
                    [FBSDKShareAPI shareWithContent:content delegate:nil];
                }
        }];
    } else
    { // share photo to Facebook
        if (view){
            [MBProgressHUD hideHUDForView:view animated:YES];
        }
        
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = image;
        photo.userGenerated = YES;
        photo.caption = desc;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = [ NSArray arrayWithObject:photo ];
        [FBSDKShareAPI shareWithContent:content delegate:delegate];
    }
}

+ (void) shareImagetoTwtter:(UIImage *)image sender:(id)delegate
{
    
}

+ (void) shareImagetoInstagram:(UIImage *)image sender:(id)delegate
{
    
}

@end
