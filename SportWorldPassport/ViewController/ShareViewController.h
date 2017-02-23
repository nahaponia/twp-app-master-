//
//  ShareViewController.h
//  SportWorldPassport
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "STTwitter.h"

@interface ShareViewController : UIViewController<STTwitterRequestProtocol>

- (void)setDetailImage:(UIImage *)image;
- (void)setDetailVideoData:(NSData *)data;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@property (nonatomic, strong) STTwitterAPI *twitter;

@end
