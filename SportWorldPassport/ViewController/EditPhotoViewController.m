//
//  EditPhotoViewController.m
//  SportWorldPassport
//
//  Created by developer on 12/07/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "EditPhotoViewController.h"
#import "CreateOneStampViewController.h"
#import "UIImage+Convenience.h"
#import "GPUImage.h"

@interface EditPhotoViewController ()
{
    IBOutlet UIImageView *editImageView;
}

@end

@implementation EditPhotoViewController

@synthesize stampObject, image;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if (stampObject) {
//        PFObject *feedObject = stampObject[PARSE_STAMP_FEED];
//        PFFile *smallImage = feedObject[PARSE_FEED_SMALL_PHOTO];
//        PFFile *normalImage = feedObject[PARSE_FEED_NORMAL_PHOTO];
//        
//        // set small image at first
////        [smallImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
////            [editImageView setImage:[UIImage imageWithData:data]];
//        
//            // set large image next time
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            [normalImage getDataInBackgroundWithBlock:^(NSData *data1, NSError *error) {
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                if (!error) {
//                    [editImageView setImage:[UIImage imageWithData:data1]];
//                }
//            }];
////        }];
//    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (image){
        [editImageView setImage:image];
        [editImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onEditPressed:(id)sender {
    CreateOneStampViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateOneStampViewController"];
    vc.feedObject = stampObject[PARSE_STAMP_FEED];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onRemovePressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure to delete this stamp?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert setTag:TAG_DELETE];
    [alert show];
}

- (void)deleteStamp {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [stampObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSInteger tag = [alertView tag];
    if (tag == TAG_DELETE) {
        if (buttonIndex == 1) {
            [self deleteStamp];
        }
    }
}

@end
