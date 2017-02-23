//
//  MainViewController.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "MainViewController.h"
#import "TabbarViewController.h"
#import "ShareViewController.h"
#import "MenuViewController.h"

#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraGridView.h"
#import "DBCameraLibraryViewController.h"
#import "DBCameraSegueViewController.h"

#import "CustomCamera.h"
#import "CustomCameraViewController.h"
#import "CustomNavigationController.h"
#import "CustomCameraSegueViewController.h"
#import "CustomCameraContainerViewController.h"
#import "LoginViewController.h"

#import "UIImage+Convenience.h"
#import "UIImage+Crop.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SDAVAssetExportSession.h"

static MainViewController *_sharedViewController = nil;

@interface MainViewController () <DBCameraViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    TabbarViewController *tabbarController;
    int currentTabIndex;
    
    CustomNavigationController *cameraNav;
    DBCameraViewController *cameraVC;
    
    IBOutlet UIButton *btnFeed;
    IBOutlet UIButton *btnSearch;
    IBOutlet UIButton *btnCamera;
    IBOutlet UIButton *btnNotification;
    IBOutlet UIButton *btnMenu;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)onSelectTab:(id)sender;

@end

@implementation MainViewController

@synthesize containerView;
@synthesize cameraState, cropRate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTabbar:)
                                                 name:NOTIFICATION_TABBAR_CHANGED
                                               object:nil];
    
    [self refreshButtons];
    
    currentTabIndex = TAB_FEED;
    [btnFeed setSelected:YES];
    
    cameraState = CAMERA_STATE_NONE;
    cropRate = CROP_1_1;
    
    _sharedViewController = self;
}

+ (MainViewController *)getInstance {
    return _sharedViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectTabbarSelf {
    currentTabIndex = 0;
    [self selectTabbarButton:0];
    [tabbarController setSelectedIndex:0];
}

- (IBAction)onSelectTab:(id)sender {
    NSInteger tag = [sender tag];
    
    if (tag == TAB_FEED || tag == TAB_SEARCH || tag == TAB_NOTIFICATION) {
        currentTabIndex = tag;
        [self selectTabbarButton:tag];
        [tabbarController setSelectedIndex:tag];
    } else if (tag == TAB_CAMERA) {
//        [self openCustomCamera];
        [self selectMomentType];
        [self selectTabbarButton:currentTabIndex];
    } else if (tag == TAB_MENU) {
        UIImage *image = [UIImage imageWithView:self.view];
        
        MenuViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        vc.lastTabIndex = currentTabIndex;
        vc.bgImage = image;
//        [self presentViewController:vc animated:YES completion:^{
//        }];
        [self pushViewControllerNoAnimate:vc];
    }
}

- (void) selectMomentType
{
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Capture a video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self openVideoCamera];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Pick a video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self openVidoeLirary];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Capture a picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self openCustomCamera];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (void)selectTabbar:(int)index {
    [self selectTabbarButton:index];
    [tabbarController setSelectedIndex:index];
}

- (void) gotoTrendingView
{
    [self selectTabbar:TAB_FEED];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_LET_ME_SEE object:nil];
}

- (void)selectTabbarButton:(int)index {
    //log out banned user
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:[AppConfig getStringValueForKey:LOGINED_USER_EMAIL]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error && object && [[object[PARSE_FEED_BANNED] lowercaseString] isEqualToString:@"true"]){
            [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                [AppConfig setStringValueForKey:LOGINED_USER_PASSWORD value:@""];
                [CommonUtils showAlertView:@"" message:@"Your account is suspended because of your actions against Terms of Service" delegate:self tag:TAG_ERROR];
                [self.navigationController popViewControllerAnimated:NO];
            }];
        }
    }];
    

    [self refreshButtons];
    switch (index) {
        case TAB_FEED:
            [btnFeed setSelected:YES];
            break;
        case TAB_SEARCH:
            [btnSearch setSelected:YES];
            break;
        case TAB_CAMERA:
            [btnCamera setSelected:YES];
            break;
        case TAB_NOTIFICATION:
            [btnNotification setSelected:YES];
            break;
        case TAB_MENU:
            [btnMenu setSelected:YES];
            break;
        default:
            break;
    }
}

- (void)changeTabbar:(NSNotification *)notif {
    int index = [[[notif userInfo] objectForKey:SELECTED_TAB_INDEX] intValue];
    [tabbarController setSelectedIndex:index];
}

- (void)refreshButtons {
    [btnFeed setSelected:NO];
    [btnSearch setSelected:NO];
    [btnCamera setSelected:NO];
    [btnNotification setSelected:NO];
    [btnMenu setSelected:NO];
}

// called when touch up inside back button
- (IBAction)goBack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTROLLER_POPUP object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        tabbarController = segue.destinationViewController;
        [tabbarController setHidesBottomBarWhenPushed:YES];
    }
}

- (void)pushViewController:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushViewControllerNoAnimate:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:NO];
}

- (UIImage *) getThumbnailWithUrl:(NSURL *) contentURL
{
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    player = nil;
    return thumbnail;
}

#pragma mark - Camera Actions

// recording video
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeMovie]){
        
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:url];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){ // pick video from Libary
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
            CGFloat width = playerItem.asset.naturalSize.width;
            CGFloat height = playerItem.asset.naturalSize.height;
            CMTime new = playerItem.asset.duration;
            float seconds = CMTimeGetSeconds(new);
            NSLog(@"duration: %.2f", seconds);
            if (seconds > 30.0f){
                [CommonUtils showAlertView:@"Warning" message:@"Sorry, video duration is longer than 30 secs" delegate:self tag:TAG_ERROR];
                [picker dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){ // capture video from Camera
            
        }
        
        float filesize = (float)videoData.length/1024.0f/1024.0f;
        NSLog(@"File size is : %.2f MB",filesize);
        if (filesize > 9.9){
            // let me compress this video file
            NSURL* uploadURL = [NSURL fileURLWithPath:
                                [NSTemporaryDirectory() stringByAppendingPathComponent:@"temporaryPreview.mov"]];
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtURL:uploadURL error:&error];
            [self compressVideo:url outputURL:uploadURL picker:picker];
            return;
        }
        
        ShareViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
        UIImage *image = [self getThumbnailWithUrl:url];
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        UIImage *newImage = image;
        if (newImage.size.width > IMAGE_SIZE_LARGE) {
            newImage = [image getCroppedImage:IMAGE_SIZE_LARGE height:IMAGE_SIZE_LARGE * imageHeight / imageWidth];
        }
        
        [detail setDetailImage:newImage];
        [detail setDetailVideoData:videoData];
        
        [picker dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController pushViewController:detail animated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)compressVideo:(NSURL *)inputURL outputURL:(NSURL *)outputURL picker:(UIImagePickerController *) picker
{
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:urlAsset];
    encoder.outputFileType = AVFileTypeQuickTimeMovie;
    encoder.outputURL = outputURL;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @1280,
    AVVideoHeightKey: @720,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @2300000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    [encoder exportAsynchronouslyWithCompletionHandler:^
    {
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Video export succeeded");
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            NSLog(@"File size is : %.2f MB",(float)videoData.length/1024.0f/1024.0f);
            ShareViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
            UIImage *image = [self getThumbnailWithUrl:outputURL];
            CGFloat imageWidth = image.size.width;
            CGFloat imageHeight = image.size.height;
            UIImage *newImage = image;
            if (newImage.size.width > IMAGE_SIZE_LARGE) {
                newImage = [image getCroppedImage:IMAGE_SIZE_LARGE height:IMAGE_SIZE_LARGE * imageHeight / imageWidth];
            }
            
            [detail setDetailImage:newImage];
            [detail setDetailVideoData:videoData];
            
            [picker dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController pushViewController:detail animated:YES];
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
            [picker dismissViewControllerAnimated:NO completion:nil];
        }
        else
        {
            NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
            [picker dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)compressVideo:(NSURL*)inputURL
            outputURL:(NSURL*)outputURL
              handler:(void (^)(AVAssetExportSession*))completion  {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(exportSession);
    }];
    
//    NSDictionary *settings = @{AVVideoCodecKey:AVVideoCodecH264,
//                               AVVideoWidthKey:@(video_width),
//                               AVVideoHeightKey:@(video_height),
//                               AVVideoCompressionPropertiesKey:
//                                   @{AVVideoAverageBitRateKey:@(desired_bitrate),
//                                     AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31, /* Or whatever profile & level you wish to use */
//                                     AVVideoMaxKeyFrameIntervalKey:@(desired_keyframe_interval)}};
//    
//    AVAssetWriterInput* writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
}

// cancel recording
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancelled");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void) openVideoCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
//        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        [picker setVideoMaximumDuration:30];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void) openVidoeLirary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        picker.allowsEditing = YES;
        [picker setVideoMaximumDuration:30];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void) openCustomCamera
{
    cameraState = CAMERA_TAKE_PHOTO;
    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildInterface];
    
//    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]];
    
    CustomCameraContainerViewController *cameraContainer = [[CustomCameraContainerViewController alloc] initWithDelegate:self];
    cameraVC = [[DBCameraViewController alloc] initWithDelegate:self cameraView:camera];
    [cameraVC setUseCameraSegue:NO];
    
    [cameraContainer setCameraViewController:cameraVC];
    
    cameraNav = [[CustomNavigationController alloc] initWithRootViewController:cameraContainer];
    
    [self presentViewController:cameraNav animated:YES completion:nil];
}

- (void) openLibrary
{
    DBCameraLibraryViewController *vc = [[DBCameraLibraryViewController alloc] init];
    [vc setDelegate:self]; //DBCameraLibraryViewController must have a DBCameraViewControllerDelegate object
    //    [vc setForceQuadCrop:YES]; //Optional
    //    [vc setUseCameraSegue:YES]; //Optional
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self selectTabbarButton:currentTabIndex];
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    if (cameraState == CAMERA_TAKE_PHOTO) {
        CGFloat newW = 256.0;
        CGFloat newH = 340.0;
        
        if ( image.size.width > image.size.height ) {
            newW = 340.0;
            newH = ( newW * image.size.height ) / image.size.width;
        }
        NSMutableDictionary *finalMetadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
        CustomCameraSegueViewController *segue = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomCameraSegueViewController"];
        [segue setSourceImage:image];
        [segue setPreviewImage:[UIImage returnImage:image withSize:(CGSize){ newW, newH }]];
        [segue enableGestures:YES];
        [segue setDelegate:self];
        [segue setCapturedImageMetadata:finalMetadata];
        [segue setCameraSegueConfigureBlock:cameraVC.cameraSegueConfigureBlock];
        
        [cameraNav pushViewController:segue animated:YES];
    } else if (cameraState == CAMERA_SET_FILTER) {
        ShareViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        NSLog(@"image size : %.2f,%.2f", imageWidth, imageHeight);
        
        UIImage *newImage = image;
        if (newImage.size.width > IMAGE_SIZE_LARGE) {
            newImage = [image getCroppedImage:IMAGE_SIZE_LARGE height:IMAGE_SIZE_LARGE * imageHeight / imageWidth];
        }
        [detail setDetailImage:newImage];
        [detail setDetailVideoData:nil];
        
        [cameraNav pushViewController:detail animated:YES];
        [cameraViewController restoreFullScreenMode];
    }
}

@end
