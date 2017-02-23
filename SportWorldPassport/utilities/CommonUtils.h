//
//  CommonUtils.h
//  SportsE
//
//  Created by star on 6/22/15.
//  Copyright (c) 2015 star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CustomIOS7AlertView.h"

@interface CommonUtils : NSObject

+ (void)showAlertView:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;

+ (void)makeCallWithNumber:(NSString *)number;


+ (UIImage *)imageWithColor:(UIColor *)color;

+ (CustomIOS7AlertView *) showCustomAlertView:(UIView *) parentView view:(UIView *) view buttonTitleList:(NSMutableArray *)buttonTitleList completionBlock: (void (^)(int buttonIndex))completionBlock;


+ (CIImage *)createQRForString:(NSString *)qrString;
+ (UIImage *)createQRCodeImageForString:(NSString *)qrString imageWidth:(float)width imageHeight:(float)height;


+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;

+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIColor *) colorWithHexString: (NSString *) hexString;

+ (void) sendEmailToAdminsWithText:(NSString *)text;

+ (void) shareImagetoFacebook:(UIImage *)image sender:(id)delegate withView:(UIView *)view andDescription:(NSString *) desc;
+ (void) shareImagetoTwtter:(UIImage *)image sender:(id)delegate;
+ (void) shareImagetoInstagram:(UIImage *)image sender:(id)delegate;

@end
