//
//  MainViewController.h
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

typedef enum {
    TAB_FEED = 0,
    TAB_SEARCH,
    TAB_NOTIFICATION,
    TAB_MENU,
    TAB_CAMERA
} TAB_INDEX;

@interface MainViewController : RootViewController

@property (nonatomic, assign) int cameraState;
@property (nonatomic, assign) int cropRate;

+ (MainViewController *)getInstance;

- (void)pushViewController:(UIViewController *)vc;

- (void)selectTabbar:(int)index;
- (void)selectTabbarSelf;
- (void)selectTabbarButton:(int)index;
- (void)gotoTrendingView; // from Search "Let me see"

@end
