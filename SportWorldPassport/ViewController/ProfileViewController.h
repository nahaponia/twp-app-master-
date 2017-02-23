//
//  ProfileViewController.h
//  SportWorldPassport
//
//  Created by star on 1/26/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) BOOL isFollowed;

@end
