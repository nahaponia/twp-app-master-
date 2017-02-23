//
//  CustomCameraSegueViewController.m
//  SportWorldPassport
//
//  Created by star on 12/11/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomCameraSegueViewController.h"
#import "DBCameraBaseCropViewController+Private.h"
#import "DBCameraCropView.h"
#import "DBCameraFiltersView.h"
#import "DBCameraFilterCell.h"
#import "CustomCameraFilterCell.h"
#import "DBCameraLoadingView.h"
#import "UIImage+TintColor.h"
#import "UIImage+Bundle.h"
#import "GrayscaleContrastFilter.h"

#import <GPUImage/GPUImage.h>
#import "MainViewController.h"

#define kFilterCellIdentifier @"filterCell"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
[[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"DBCamera" ofType:@"bundle"]] localizedStringForKey:(key) value:@"" table:@"DBCamera"]
#endif

#define buttonMargin 20.0f

static const CGSize kFilterCellSize = { 90, 110 };

@interface CustomCameraSegueViewController () <UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    DBCameraCropView *_cropView;
    
    NSArray *_cropArray, *_filtersList;
    GPUImageVignetteFilter *vignetteFilter;
    GPUImageFilterGroup *vignetteFilterGroup;
    GPUImageToneCurveFilter *vignetteToneCurveFilter;
    NSDictionary *_filterMapping;
    CGRect _pFrame, _lFrame;
}

@property (nonatomic, strong) UIView *navigationBar, *bottomBar;
@property (nonatomic, strong) UIButton *useButton, *retakeButton, *cropButton;
@property (nonatomic, strong) DBCameraLoadingView *loadingView;

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;
@property (strong, nonatomic) IBOutlet UIView *filterContainerView;
@property (strong, nonatomic) IBOutlet UIView *cropControlView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *btnFilter;
@property (strong, nonatomic) IBOutlet UIButton *btnCrop;
@property (strong, nonatomic) IBOutlet UIButton *btnCropCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnCropApply;
@property (strong, nonatomic) IBOutlet UIButton *btnCrop4_3;
@property (strong, nonatomic) IBOutlet UIButton *btnCrop3_4;
@property (strong, nonatomic) IBOutlet UIButton *btnCrop1_1;

- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onCropImage:(id)sender;
- (IBAction)onCropCancel:(id)sender;
- (IBAction)onCropApply:(id)sender;
- (IBAction)onShowFilter:(id)sender;
- (IBAction)onShowCrop:(id)sender;

@end

@implementation CustomCameraSegueViewController

@synthesize forceQuadCrop = _forceQuadCrop;
@synthesize useCameraSegue = _useCameraSegue;
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;
@synthesize cameraSegueConfigureBlock = _cameraSegueConfigureBlock;

@synthesize imageContainerView;
@synthesize filterContainerView;
@synthesize cropControlView;
@synthesize btnFilter;
@synthesize btnCrop;
@synthesize btnCropCancel;
@synthesize btnCropApply;
@synthesize btnCrop4_3;
@synthesize btnCrop3_4;
@synthesize btnCrop1_1;

- (id) initWithImage:(UIImage *)image thumb:(UIImage *)thumb {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)initVignetteFilter {
    vignetteFilter = [[GPUImageVignetteFilter alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *vignetteFilterACVURL = [NSURL fileURLWithPath:[bundle pathForResource:@"Vignette" ofType:@"acv"]];
    vignetteToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:vignetteFilterACVURL];
    vignetteFilterGroup = [[GPUImageFilterGroup alloc] init];
    
    [vignetteFilterGroup addFilter:vignetteToneCurveFilter];
    [vignetteFilterGroup addFilter:vignetteFilter];
    
    [vignetteToneCurveFilter addTarget:vignetteFilter];
    [vignetteFilterGroup setInitialFilters:[NSArray arrayWithObject:vignetteToneCurveFilter]];
    [vignetteFilterGroup setTerminalFilter:vignetteFilter];
}

- (void)viewDidLoad
{
    
    // Do any additional setup after loading the view.
    
    [self initVignetteFilter];
    
    // initialize in init function
    _cropArray = @[ @0.75, @1.33, @1, @192, @180 ];
    _filtersList = @[ @"normal", @"1977", @"amaro", @"grey", @"hudson", @"mayfair", @"nashville", @"valencia", @"contrastgrey", @"vignette" ];
    
    NSBundle *bundle        = [NSBundle bundleForClass:self.class];
    NSURL *filter1977       = [NSURL fileURLWithPath:[bundle pathForResource:@"1977"      ofType:@"acv"]];
    NSURL *filterAmaro      = [NSURL fileURLWithPath:[bundle pathForResource:@"amaro"     ofType:@"acv"]];
    NSURL *filterHudson     = [NSURL fileURLWithPath:[bundle pathForResource:@"Hudson"    ofType:@"acv"]];
    NSURL *filterMayfair    = [NSURL fileURLWithPath:[bundle pathForResource:@"mayfair"   ofType:@"acv"]];
    NSURL *filterNashville  = [NSURL fileURLWithPath:[bundle pathForResource:@"Nashville" ofType:@"acv"]];
    NSURL *filterValencia   = [NSURL fileURLWithPath:[bundle pathForResource:@"1977"      ofType:@"acv"]];
    
    _filterMapping = @{ @0:[[GPUImageFilter alloc] init],
                        @1:[[GPUImageToneCurveFilter alloc] initWithACVURL:filter1977],
                        @2:[[GPUImageToneCurveFilter alloc] initWithACVURL:filterAmaro],
                        @3:[[GPUImageGrayscaleFilter alloc] init],
                        @4:[[GPUImageToneCurveFilter alloc] initWithACVURL:filterHudson],
                        @5:[[GPUImageToneCurveFilter alloc] initWithACVURL:filterMayfair],
                        @6:[[GPUImageToneCurveFilter alloc] initWithACVURL:filterNashville],
                        @7:[[GPUImageToneCurveFilter alloc] initWithACVURL:filterValencia],
                        @8:[[GrayscaleContrastFilter alloc] init],
                        @9:vignetteFilterGroup};
    
    _selectedFilterIndex = 0;
    
    [self setCropRect:(CGRect){ 0, 320 }];
    [self setMinimumScale:.2];
    [self setMaximumScale:10];
    [self createInterface];
    
    [super viewDidLoad];
    
    [self.view setUserInteractionEnabled:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat cropX = ( CGRectGetWidth( self.frameView.frame) - 320 ) * .5;
    _pFrame = (CGRect){ cropX, ( CGRectGetHeight( self.frameView.frame) - 360 ) * .5, 320, 320 };
    _lFrame = (CGRect){ cropX, ( CGRectGetHeight( self.frameView.frame) - 240) * .5, 320, 240 };
    [self setCropRect:self.previewImage.size.width > self.previewImage.size.height ? _lFrame : _pFrame];
    
    [self.filterContainerView addSubview:self.filtersView];
    
    [self.view bringSubviewToFront:self.frameView];
    [self.view bringSubviewToFront:self.navView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view setClipsToBounds:YES];
    [self.imageView setClipsToBounds:YES];
    
    [btnCrop1_1 setSelected:YES];
    [btnFilter setSelected:YES];
    
    if( self.cameraSegueConfigureBlock )
        self.cameraSegueConfigureBlock(self);

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MainViewController getInstance].cameraState = CAMERA_SET_FILTER;
    if ( _forceQuadCrop ) {
        [self setCropMode:YES];
        [self setCropRect:_pFrame];
        [self reset:YES];
    }
    
    if ( _cropMode )
        [_cropButton setSelected:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cropModeAction:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    [self setCropMode:button.isSelected];
    [self setCropRect:button.isSelected ? _pFrame : _lFrame];
    [self reset:YES];
}

- (void) openActionsheet:(UIButton *)button
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:DBCameraLocalizedStrings(@"general.button.cancel") destructiveButtonTitle:nil otherButtonTitles:DBCameraLocalizedStrings(@"cropmode.square"), @"3:2", @"4:3", @"5:3", @"16:9", nil];
    [actionSheet showInView:self.view];
}

- (void) createInterface
{
//    CGFloat viewHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]) - 64 - 40;
    _cropView = [[DBCameraCropView alloc] initWithFrame:(CGRect){ 0, 66, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetWidth([[UIScreen mainScreen] bounds]) }];
    [_cropView setHidden:YES];
    
    [self setFrameView:_cropView];
}

- (void) retakeImage
{
    [self.navigationController popViewControllerAnimated:YES];
    [self setSourceImage:nil];
    [self setPreviewImage:nil];
}

- (void) saveImage
{
    if ( [_delegate respondsToSelector:@selector(camera:didFinishWithImage:withMetadata:)] ) {
        if ( _cropMode )
            [self cropImage];
        else {
            UIImage *transform = [_filterMapping[@(_selectedFilterIndex.row)] imageByFilteringImage:self.sourceImage];
            [_delegate camera:self didFinishWithImage:transform withMetadata:self.capturedImageMetadata];
        }
    }
}

- (void) cropImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef resultRef = [self newTransformedImage:self.imageView.transform
                                             sourceImage:self.sourceImage.CGImage
                                              sourceSize:self.sourceImage.size
                                       sourceOrientation:self.sourceImage.imageOrientation
                                             outputWidth:self.outputWidth ? self.outputWidth : self.sourceImage.size.width
                                                cropRect:self.cropRect
                                           imageViewSize:self.imageView.bounds.size];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *transform =  [UIImage imageWithCGImage:resultRef scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(resultRef);
            transform = [_filterMapping[@(_selectedFilterIndex.row)] imageByFilteringImage:transform];
            [_delegate camera:self didFinishWithImage:transform withMetadata:self.capturedImageMetadata];
        });
    });
}

- (void) setCropMode:(BOOL)cropMode
{
    _cropMode = cropMode;
    [self.frameView setHidden:!_cropMode];
    
    // Only hide filters if quad crop is not forced, otherwise filters are not accessible
    if (!_forceQuadCrop) {
        [self.bottomBar setHidden:!_cropMode];
        [self.filtersView setHidden:_cropMode];
    }
}

- (DBCameraFiltersView *) filtersView
{
    if ( !_filtersView ) {
        CGFloat cellHeight = kFilterCellSize.height * SCREEN_WIDTH / 320;
        CGFloat padding = 10 * SCREEN_WIDTH / 320;
        _filtersView = [[DBCameraFiltersView alloc] initWithFrame:(CGRect){ 0, padding, CGRectGetWidth(self.view.frame), cellHeight} collectionViewLayout:[DBCameraFiltersView filterLayout]];
        [_filtersView setBackgroundColor:[UIColor clearColor]];
        [_filtersView setDelegate:self];
        [_filtersView setDataSource:self];
        _filtersView.showsVerticalScrollIndicator = false;
        _filtersView.showsHorizontalScrollIndicator = false;
        [_filtersView registerClass:[CustomCameraFilterCell class] forCellWithReuseIdentifier:kFilterCellIdentifier];
    }
    
    return _filtersView;
}

- (DBCameraLoadingView *) loadingView
{
    if ( !_loadingView ) {
        _loadingView = [[DBCameraLoadingView alloc] initWithFrame:(CGRect){ 0, 0, 100, 100 }];
        [_loadingView setCenter:self.view.center];
    }
    
    return _loadingView;
}

- (UIView *) navigationBar
{
    if ( !_navigationBar ) {
        _navigationBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, [[UIScreen mainScreen] bounds].size.width, 64 }];
        [_navigationBar setBackgroundColor:[UIColor blackColor]];
        [_navigationBar setUserInteractionEnabled:YES];
        [_navigationBar addSubview:self.useButton];
        [_navigationBar addSubview:self.retakeButton];
        if ( !_forceQuadCrop )
            [_navigationBar addSubview:self.cropButton];
    }
    
    return _navigationBar;
}

- (UIView *) bottomBar
{
    if ( !_bottomBar ) {
        _bottomBar = [[UIView alloc] initWithFrame:(CGRect){ 0, CGRectGetHeight([[UIScreen mainScreen] bounds]) - 40, [[UIScreen mainScreen] bounds].size.width, 40 }];
        [_bottomBar setBackgroundColor:[UIColor blackColor]];
        [_bottomBar setHidden:YES];
        
        if ( !_forceQuadCrop ) {
            UIButton *actionsheetButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [actionsheetButton setFrame:_bottomBar.bounds];
            [actionsheetButton setBackgroundColor:[UIColor clearColor]];
            [actionsheetButton setTitle:DBCameraLocalizedStrings(@"cropmode.title") forState:UIControlStateNormal];
            [actionsheetButton addTarget:self action:@selector(openActionsheet:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomBar addSubview:actionsheetButton];
        }
    }
    
    return _bottomBar;
}

- (UIButton *) useButton
{
    if ( !_useButton ) {
        _useButton = [self baseButton];
        [_useButton setTitle:[DBCameraLocalizedStrings(@"button.use") uppercaseString] forState:UIControlStateNormal];
        [_useButton.titleLabel sizeToFit];
        [_useButton sizeToFit];
        [_useButton setFrame:(CGRect){ CGRectGetWidth(self.view.frame) - (CGRectGetWidth(_useButton.frame) + buttonMargin), 0, CGRectGetWidth(_useButton.frame) + buttonMargin, 60 }];
        [_useButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _useButton;
}

- (UIButton *) retakeButton
{
    if ( !_retakeButton ) {
        _retakeButton = [self baseButton];
        [_retakeButton setTitle:[DBCameraLocalizedStrings(@"button.retake") uppercaseString] forState:UIControlStateNormal];
        [_retakeButton.titleLabel sizeToFit];
        [_retakeButton sizeToFit];
        [_retakeButton setFrame:(CGRect){ 0, 0, CGRectGetWidth(_retakeButton.frame) + buttonMargin, 60 }];
        [_retakeButton addTarget:self action:@selector(retakeImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _retakeButton;
}

- (UIButton *) cropButton
{
    if ( !_cropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setBackgroundColor:[UIColor clearColor]];
        [_cropButton setImage:[[UIImage imageInBundleNamed:@"Crop"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_cropButton setImage:[[UIImage imageInBundleNamed:@"Crop"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_cropButton setFrame:(CGRect){ CGRectGetMidX(self.view.bounds) - 15, 15, 30, 30 }];
        [_cropButton addTarget:self action:@selector(cropModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cropButton;
}

- (UIButton *) baseButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    
    return button;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filtersList.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBCameraFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFilterCellIdentifier forIndexPath:indexPath];
    [cell.imageView setImage:[_filterMapping[@(indexPath.row)] imageByFilteringImage:self.previewImage]];
    [cell.label setText:[_filtersList[indexPath.row] uppercaseString]];
    [cell.imageView.layer setBorderWidth:(self.selectedFilterIndex.row == indexPath.row) ? 1.0 : 0.0];
    
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rate = SCREEN_WIDTH / 320.0;
    return CGSizeMake(kFilterCellSize.width * rate, kFilterCellSize.height * rate);
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view addSubview:self.loadingView];
    
    _selectedFilterIndex = indexPath;
    [self.filtersView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *filteredImage = [_filterMapping[@(indexPath.row)] imageByFilteringImage:self.sourceImage];
        [self.loadingView removeFromSuperview];
        [self.imageView setImage:filteredImage];
    });
}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != actionSheet.cancelButtonIndex ) {
        NSUInteger height = [_cropArray[buttonIndex] integerValue];
        CGFloat cropX = ( CGRectGetWidth( self.frameView.frame) - 320 ) * .5;
        CGRect cropRect = (CGRect){ cropX, ( CGRectGetHeight( self.frameView.frame) - (CGRectGetHeight(self.bottomBar.frame) + height) ) * .5, 320, height };
        
        [self setCropRect:cropRect];
        [self reset:YES];
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    [self saveImage];
}

- (IBAction)onCropImage:(id)sender {
    [btnCrop1_1 setSelected:NO];
    [btnCrop3_4 setSelected:NO];
    [btnCrop4_3 setSelected:NO];
    
    UIButton *selectedButton = (UIButton *)sender;
    [selectedButton setSelected:YES];
    
    int tag = [sender tag];
    [MainViewController getInstance].cropRate = tag;
    CGFloat cropRate = (tag == CROP_3_4 ? 1.33 : (tag == CROP_4_3 ? 0.75 : 1));
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = cropRate * width;
    
    if (height > width) {
        width = width * SCREEN_WIDTH / height;
        height = SCREEN_WIDTH;
    }
    
    CGFloat cropX = ( CGRectGetWidth(self.frameView.frame) - SCREEN_WIDTH) * .5;
    CGRect cropRect = (CGRect){ cropX, (width >= height ? (width - height): 0) / 2 + 66, width, height };
    
    [self setCropMode:YES];
    [self setCropRect:cropRect];
    [self reset:YES];
}

- (IBAction)onCropCancel:(id)sender {
    [MainViewController getInstance].cropRate = CROP_1_1;
    
    [btnCropCancel setSelected:YES];
    [self cropModeAction:btnCropCancel];
}

- (IBAction)onCropApply:(id)sender {
    [btnCropApply setSelected:NO];
    [self cropModeAction:btnCropApply];
}

- (IBAction)onShowFilter:(id)sender {
    if (![btnFilter isSelected]) {
        [btnFilter setSelected:YES];
        [btnCrop setSelected:NO];
        
        [filterContainerView setHidden:NO];
        [cropControlView setHidden:YES];
    }
}

- (IBAction)onShowCrop:(id)sender {
    if (![btnCrop isSelected]) {
        [btnFilter setSelected:NO];
        [btnCrop setSelected:YES];
        
        [filterContainerView setHidden:YES];
        [cropControlView setHidden:NO];
    }
}

@end
