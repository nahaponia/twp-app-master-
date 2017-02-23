//
//  UserOperationViewController.m
//  SportWorldPassport
//
//  Created by developer on 01/09/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "UserOperationViewController.h"
#import "GPUImage.h"
#import "MainViewController.h"

@interface UserOperationViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIButton *btnBlock;

@end

NSMutableArray *blockedArray;
NSMutableArray *blockedOtherArray;

@implementation UserOperationViewController
@synthesize user, isBlocking;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (self.bgImage) {
        // add the blur effect view to the image view
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 15.0;
        
        _bgImageView.image = [blurFilter imageByFilteringImage: self.bgImage];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFUser query];  //mine
    [query whereKey:PARSE_USER_EMAIL equalTo:[AppConfig getStringValueForKey:LOGINED_USER_EMAIL]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        blockedArray = object[PARSE_USER_BLOCKED];
        if (!blockedArray){
            blockedArray = [[NSMutableArray alloc] init];
        }
    }];
    
    PFQuery *query1 = [PFUser query];  //other
    [query1 whereKey:PARSE_USER_EMAIL equalTo:user[PARSE_USER_EMAIL]];
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        blockedOtherArray = object[PARSE_USER_BLOCKED];
        if (!blockedOtherArray){
            blockedOtherArray = [[NSMutableArray alloc] init];
        }
    }];
    
    if (!isBlocking){
        [_btnBlock setTitle:@"Unblock this User" forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)onReportUser:(id)sender {
    if (!user){
        [self onCancel:nil];
        return;
    }

    [PFCloud callFunction:@"editUser" withParameters:@{
                                                       @"userId": user.objectId,
                                                       @"flagged": @"true",
                                                       @"banned": @"false",
                                                       @"blocked": user[PARSE_USER_BLOCKED]
                                                       }];
    
    //send email
    // user has flagged a moment. The objectId of moment is ""
    NSString *message = [NSString stringWithFormat:@"The user \"%@\" has flagged a User. The objectId of User is %@.", [AppConfig getStringValueForKey:LOGINED_USER_NAME], user.objectId];
    [CommonUtils sendEmailToAdminsWithText:message];
    [CommonUtils showAlertView:@"Flagged!" message:@"User has been flagged and will be reviewed shortly - sorry for the inconvenience" delegate:self tag:TAG_NOTE];
    
    [self onCancel:nil];
}
- (IBAction)onBlockUser:(id)sender {
    PFUser *me = [PFUser currentUser];
    if (!me[PARSE_FEED_FLAG]){
        me[PARSE_FEED_FLAG] = @"false";
    }
    if (!me[PARSE_FEED_BANNED]){
        me[PARSE_FEED_BANNED] = @"false";
    }
    
    if (isBlocking){
        [blockedArray addObject:user.objectId];
        [blockedOtherArray addObject:[PFUser currentUser].objectId];
        //me
        [PFCloud callFunction:@"editUser" withParameters:@{
                                                           @"userId": me.objectId,
                                                           @"flagged": me[PARSE_FEED_FLAG],
                                                           @"banned": me[PARSE_FEED_BANNED],
                                                           @"blocked": blockedArray
                                                           }];
        //other
        [PFCloud callFunction:@"editUser" withParameters:@{
                                                           @"userId": user.objectId,
                                                           @"flagged": @"true",
                                                           @"banned": @"false",
                                                           @"blocked": blockedOtherArray
                                                           }];
    
    } else {
        [blockedArray removeObject:user.objectId];
        [blockedOtherArray removeObject:[PFUser currentUser].objectId];
        //me
        [PFCloud callFunction:@"editUser" withParameters:@{
                                                           @"userId": me.objectId,
                                                           @"flagged": me[PARSE_FEED_FLAG],
                                                           @"banned": me[PARSE_FEED_BANNED],
                                                           @"blocked": blockedArray
                                                           }];
        //other
        [PFCloud callFunction:@"editUser" withParameters:@{
                                                           @"userId": user.objectId,
                                                           @"flagged": @"true",
                                                           @"banned": @"false",
                                                           @"blocked": blockedOtherArray
                                                           }];
    }

    if (isBlocking){
        [[MainViewController getInstance] selectTabbarSelf]; // goto Feeds Scenes
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
