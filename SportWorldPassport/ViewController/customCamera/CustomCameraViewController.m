//
//  CustomCameraViewController.m
//  SportWorldPassport
//
//  Created by star on 12/11/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomCameraViewController.h"
#import "DBCameraSegueViewController.h"
#import "CustomCameraSegueViewController.h"

#import "UIImage+Crop.h"

@interface CustomCameraViewController ()

@end

@implementation CustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
//    super.processingPhoto = NO;
    
    NSMutableDictionary *finalMetadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
    finalMetadata[@"DBCameraSource"] = @"Camera";
    
    if ( !self.useCameraSegue ) {
        if ( [super.delegate respondsToSelector:@selector(camera:didFinishWithImage:withMetadata:)] )
            [super.delegate camera:self didFinishWithImage:image withMetadata:finalMetadata];
    } else {
//        CGFloat newW = 256.0;
//        CGFloat newH = 340.0;
//        
//        if ( image.size.width > image.size.height ) {
//            newW = 340.0;
//            newH = ( newW * image.size.height ) / image.size.width;
//        }
//        
//        CustomCameraSegueViewController *segue = [[CustomCameraSegueViewController alloc] initWithImage:image thumb:[UIImage returnImage:image withSize:(CGSize){ newW, newH }]];
//        [segue setTintColor:self.tintColor];
//        [segue setSelectedTintColor:self.selectedTintColor];
////        [segue setForceQuadCrop:self.delegate _forceQuadCrop];
//        [segue enableGestures:YES];
//        [segue setDelegate:self.delegate];
//        [segue setCapturedImageMetadata:finalMetadata];
//        [segue setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];
//        
//        [self.navigationController pushViewController:segue animated:YES];
    }
}

@end
