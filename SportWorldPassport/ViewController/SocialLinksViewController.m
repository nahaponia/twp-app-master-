//
//  SocialLinksViewController.m
//  SportWorldPassport
//
//  Created by developer on 19/10/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "SocialLinksViewController.h"
#import "AppConfig.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SocialLinksViewController ()
@property (strong, nonatomic) IBOutlet NormalButton *btnFacebook;
@property (strong, nonatomic) IBOutlet NormalButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UIImageView *imgFB;
@property (strong, nonatomic) IBOutlet UIImageView *imgTWT;

@end

@implementation SocialLinksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([FBSDKAccessToken currentAccessToken]){
        [_btnFacebook setTitle:@"Disconnect" forState:UIControlStateNormal];
        [_btnFacebook setHidden:NO];
        [_imgFB setImage:[UIImage imageNamed:@"ic_fb_e"]];
    } else {
        [_btnFacebook setHidden:YES];
        [_btnFacebook setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_imgFB setImage:[UIImage imageNamed:@"ic_fb_d"]];
    }
    
    if ([AppConfig getBoolValueForKey:TWITTER_LOGGED_IN]){
        [_btnTwitter setHidden:NO];
        [_btnTwitter setTitle:@"Disconnect" forState:UIControlStateNormal];
        [_imgTWT setImage:[UIImage imageNamed:@"ic_twt_e"]];
    } else {
        [_btnTwitter setTitle:@"Connect" forState:UIControlStateNormal];
        [_btnTwitter setHidden:YES];
        [_imgTWT setImage:[UIImage imageNamed:@"ic_twt_d"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPressBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


// UIbuttons
- (IBAction)onFacebook:(id)sender {
    if ([FBSDKAccessToken currentAccessToken]){
        [self disconnectFacebook];
    } else {
        [self connectFacebook];
    }
}

- (IBAction)onTwitter:(id)sender {
    if ([AppConfig getBoolValueForKey:TWITTER_LOGGED_IN]){
        [self disconnectTwitter];
    } else {
        [self connectTwitter];
    }
}

- (void) connectFacebook
{
    
}

- (void) disconnectFacebook
{
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [[FBSDKLoginManager new] logOut];
    [AppConfig setBoolValueForKey:FACEBOOK_LOGGED_IN value:NO];
    [AppConfig setStringValueForKey:@"TwitterToken" value:@""];
    [AppConfig setStringValueForKey:@"TwitterTokenSecret" value:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Safari"]];
    [self onPressBack:nil];
}

- (void) connectTwitter
{
    
}

- (void) disconnectTwitter
{
    [AppConfig setBoolValueForKey:TWITTER_LOGGED_IN value:NO];
    [self onPressBack:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
