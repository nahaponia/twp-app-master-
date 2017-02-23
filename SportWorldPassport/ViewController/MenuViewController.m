//
//  MenuViewController.m
//  SportWorldPassport
//
//  Created by star on 12/10/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "MenuViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "MyProfileViewController.h"
#import "SettingsViewController.h"
#import "InviteViewController.h"
#import "StampViewController.h"
#import "UnblockViewController.h"
#import "SocialLinksViewController.h"

#import "GPUImage.h"

@interface MenuViewController ()
{
    IBOutlet UIImageView *bgImageView;
}

- (IBAction)onPrintStamp:(id)sender;
- (IBAction)onMyProfile:(id)sender;
- (IBAction)onSettings:(id)sender;
- (IBAction)onInvite:(id)sender;
- (IBAction)onLogout:(id)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (self.bgImage) {
        // add the blur effect view to the image view
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 15.0;
        
        bgImageView.image = [blurFilter imageByFilteringImage: self.bgImage];
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [gesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:gesture];
    [self.view setUserInteractionEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTap:(UIGestureRecognizer *)gesture {
    
    // restore last selected tab button in main screen
    if (self.lastTabIndex >= 0) {
        [[MainViewController getInstance] selectTabbarButton:self.lastTabIndex];
    }
    
    // dismiss menu view
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    
    [self.navigationController popViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onPrintStamp:(id)sender {
    StampViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StampViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:^{ }];
}

- (IBAction)onMyProfile:(id)sender {
    MyProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:^{ }];
}

- (IBAction)onUnblock:(id)sender {
    UnblockViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UnblockViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onSettings:(id)sender {
    SettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:^{ }];
}

- (IBAction)onInvite:(id)sender {
    InviteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:^{ }];
}

- (IBAction)onMediaLinks:(id)sender {
    SocialLinksViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SocialLinksViewController"];
    [[MainViewController getInstance] pushViewController:vc];
//    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)onLogout:(id)sender {
//    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
//        [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:@""];
//        [self dismissViewControllerAnimated:NO completion:^{
//            for (UIViewController *vc in [MainViewController getInstance].navigationController.viewControllers) {
//                if ([vc isKindOfClass:[LoginViewController class]]) {
//                    [[MainViewController getInstance].navigationController popToViewController:vc animated:YES];
//                    break;
//                }
//            }
//        }];
//    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error){
            [CommonUtils showAlertView:@"Log out Error!" message:error.description delegate:self tag:TAG_ERROR];
        } else {
            [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:@""];
            for (UIViewController *vc in [MainViewController getInstance].navigationController.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [[MainViewController getInstance].navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
//            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}
@end
