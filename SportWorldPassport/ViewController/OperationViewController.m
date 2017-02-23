//
//  OperationViewController.m
//  SportWorldPassport
//
//  Created by User 10 on 7/17/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "OperationViewController.h"

#import "GPUImage.h"

@interface OperationViewController ()
{
    IBOutlet UIImageView *bgImageView;
}

@end

@implementation OperationViewController
@synthesize stampArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (self.bgImage) {
        // add the blur effect view to the image view
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 15.0;
        
        bgImageView.image = [blurFilter imageByFilteringImage: self.bgImage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (IBAction)onDeletePressed:(id)sender {
    if (stampArray.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Selected Stamps" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to delete selected stamp(s)?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert setTag:TAG_DELETE];
    [alert show];
}
- (void)deleteStamp {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     for(int i=0;i<stampArray.count;i++){
         PFObject *obj = [stampArray objectAtIndex:i];
//         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                  (unsigned long)NULL), ^(void) {
             [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 if (error){
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     [CommonUtils showAlertView:@"Deleting Error" message:error.description delegate:self tag:TAG_ERROR];
                 } else if (i == stampArray.count-1){
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
             }];
//         });
     }
}
- (IBAction)onSaveCameraRollPressed:(id)sender {
    if (stampArray.count == 0){
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    for (int i=0;i<stampArray.count;i++) {
        PFObject *obj = [stampArray objectAtIndex:i];
        PFObject *feedObject = obj[PARSE_STAMP_FEED];
        PFFile *smallImage = feedObject[PARSE_FEED_SMALL_PHOTO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            [smallImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *img = [UIImage imageWithData:data];
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil); //save camera roll
            }];
        });
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger tag = [alertView tag];
    if (tag == TAG_DELETE) {
        if (buttonIndex == 1) {
            [self deleteStamp];
        }
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
