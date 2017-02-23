//
//  MenuViewController.h
//  SportWorldPassport
//
//  Created by star on 12/10/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "RootViewController.h"

@interface MenuViewController : RootViewController

// last selected index of tabbar button in main screen
@property (nonatomic, assign) int lastTabIndex;
@property (nonatomic, strong) UIImage *bgImage;

@end
