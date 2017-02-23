//
//  SplashViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "SplashViewController.h"
#import "LoadingView.h"
#import "LoginViewController.h"
#import "MainViewController.h"

@interface SplashViewController()
{
    BOOL isFinishedLoading;
    BOOL isLogined;
    
    IBOutlet LoadingView *loadingView;
}

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFinishedLoading = NO;
    isLogined = NO;
    
    NSString *username = [AppConfig getStringValueForKey:LOGINED_USER_NAME];
    NSString *password = [AppConfig getStringValueForKey:LOGINED_USER_PASSWORD];
    if (![username isEqualToString:@""] && ![password isEqualToString:@""]) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {            
            if (user) {
                PFInstallation *installObject = [PFInstallation currentInstallation];
                installObject[PARSE_FIELD_USER] = user;
                [installObject saveInBackground];
                
                isLogined = YES;
            }
            
            if (isFinishedLoading) {
                [self gotoNextScreen];
            } else {
                isFinishedLoading = YES;
                [loadingView accelerate];
            }
        }];
    } else {
        isFinishedLoading = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat loadTime = isFinishedLoading ? QUICK_LOAD_TIME : LOAD_TIME;
    [loadingView initWithTotal:loadTime TimerMode:true Delegate:self];
    [loadingView start];
}

- (void)timerFinished:(id)view
{
    [loadingView stop];
    
    if (isFinishedLoading) {
        [self gotoNextScreen];
    } else {
        isFinishedLoading = YES;
    }
}

- (void)gotoNextScreen {

    UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    if (isLogined) {
        [self.navigationController pushViewController:loginVC animated:NO];
        UIViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.navigationController pushViewController:mainVC animated:YES];
    } else {
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    
    
}

@end
