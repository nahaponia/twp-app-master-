//
//  RootViewController.m
//  SportWorldPassport
//
//  Created by star on 7/6/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "RootViewController.h"

#import "KeyboardManager.h"

@interface RootViewController ()

{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
    
    UIButton *backButton;
    UIButton *settingButton;
    UIBarButtonItem *backBarButtonItem;
    UIBarButtonItem *settingButtonItem;
}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setKeyBoard];
    [self setNavBarStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)setKeyBoard
{
    [[IQKeyboardManager sharedManager] setOverrideKeyboardAppearance:NO];
    [[IQKeyboardManager sharedManager] setKeyboardAppearance:UIKeyboardAppearanceDefault];
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
    [[IQKeyboardManager sharedManager] keyboardDistanceFromTextField];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
}


// hide navigation shadow
- (void)setNavBarStyle {
    self.navigationController.navigationBarHidden = YES;
}

- (void)showBackButton {
    // back button item
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 22, 22);
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)showSettingButton {
    // setting bar button
    settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.frame = CGRectMake(0, 0, 22, 22);
    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setBackgroundImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    self.navigationItem.rightBarButtonItem = settingButtonItem;
}

- (void)hideLeftBarButton {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)hideRightBarButton {
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showSetting:(id)sender {
    
}

@end
