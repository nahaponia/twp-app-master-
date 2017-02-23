//
//  CustomCameraContainerViewController.m
//  SportWorldPassport
//
//  Created by star on 12/18/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomCameraContainerViewController.h"
#import "MainViewController.h"

@interface CustomCameraContainerViewController ()

@end

@implementation CustomCameraContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MainViewController getInstance].cameraState = CAMERA_TAKE_PHOTO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
