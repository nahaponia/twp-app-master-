//
//  UserOperationViewController.h
//  SportWorldPassport
//
//  Created by developer on 01/09/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserOperationViewController : UIViewController
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic) bool isBlocking;
@end
