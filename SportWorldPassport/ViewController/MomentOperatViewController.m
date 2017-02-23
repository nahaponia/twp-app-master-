//
//  MomentOperatViewController.m
//  SportWorldPassport
//
//  Created by developer on 01/09/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "MomentOperatViewController.h"
#import "GPUImage.h"
#import "CommonUtils.h"

@interface MomentOperatViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation MomentOperatViewController
@synthesize feedObject;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCancel:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onReportInvalid:(id)sender {
    if (!feedObject){
        [self onCancel:nil];
        return;
    }
    if ([[feedObject[PARSE_FEED_CLEAND] lowercaseString] isEqualToString:@"true"]){ // Cleand
        [self onCancel:nil];
        return;
    }
    feedObject[PARSE_FEED_FLAG] = @"true";
    feedObject[PARSE_FEED_BANNED] = @"false";
    feedObject[PARSE_FEED_CLEAND] = @"false";
    [feedObject save];
    
    //send email
    // user has flagged a moment. The objectId of moment is ""
    NSString *message = [NSString stringWithFormat:@"The user \"%@\" has flagged a moment. The objectId of moment is %@.", [AppConfig getStringValueForKey:LOGINED_USER_NAME], feedObject.objectId];
    [CommonUtils sendEmailToAdminsWithText:message];
    [CommonUtils showAlertView:@"Flagged!" message:@"Moment has been flagged and will be reviewed shortly - sorry for the inconvenience" delegate:self tag:TAG_NOTE];

    [self onCancel:nil];
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
