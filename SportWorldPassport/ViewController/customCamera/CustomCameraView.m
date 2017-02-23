//
//  CustomCameraView.m
//  SportWorldPassport
//
//  Created by star on 12/11/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomCameraView.h"
#import "DBLibraryManager.h"

#import <AssetsLibrary/AssetsLibrary.h>

static float padding = 14;
@implementation CustomCameraView
{
    UIView *topContainerBar;
    UIView *bottomContainerBar;
    
    UIButton *closeButton;
    
    CALayer *focusBox;
    CALayer *exposeBox;
    
    CGFloat topBarHeight;
    CGFloat bottomBarHeight;
}

- (void) buildInterface
{
    // top, bottom, center view group
    [self addSubview:self.topContainerBar];
    [self addSubview:self.bottomContainerBar];
    
    // top control buttons
    [self.topContainerBar addSubview:self.closeButton];
    [self.topContainerBar addSubview:self.flashButton];
    [self.topContainerBar addSubview:self.cameraButton];
    
    // bottom buttons
    [self.bottomContainerBar addSubview:self.triggerButton];
    [self.bottomContainerBar addSubview:self.photoLibraryButton];
    
    [self.previewLayer addSublayer:self.focusBox];
    [self.previewLayer addSublayer:self.exposeBox];
    
    [self createGesture];
    
    // add gallery image
    if ( [ALAssetsLibrary authorizationStatus] !=  ALAuthorizationStatusDenied ) {
        __weak DBCameraView *weakCamera = self;
        [[DBLibraryManager sharedInstance] loadLastItemWithBlock:^(BOOL success, UIImage *image) {
            [weakCamera.photoLibraryButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
    }
}

- (UIView *)topContainerBar {
    if ( !topContainerBar ) {
        topBarHeight = 65 * self.frame.size.width / 320.0;
        topContainerBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, topBarHeight)];
        [topContainerBar setBackgroundColor:[UIColor colorWithRed:24/255.0 green:48/255.0 blue:88/255.0 alpha:0.9]];
    }
    
    return topContainerBar;
}

- (UIView *)bottomContainerBar {
    if ( !bottomContainerBar ) {
        bottomBarHeight = 76 * self.frame.size.width / 320.0;
        bottomContainerBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - bottomBarHeight, self.frame.size.width, bottomBarHeight)];
        [bottomContainerBar setBackgroundColor:[UIColor colorWithRed:128/255.0 green:138/255.0 blue:156/255.2 alpha:0.5]];
    }
    
    return bottomContainerBar;
}

- (UIButton *) closeButton
{
    if ( !closeButton ) {
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        [closeButton setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
        
        [closeButton setFrame:(CGRect){ padding, topBarHeight - 26 - padding, 26, 26 }];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return closeButton;
}

- (UIButton *) flashButton
{
    if (super.flashButton) {
        [super.flashButton setBackgroundColor:[UIColor clearColor]];
        [super.flashButton setImage:[UIImage imageNamed:@"ic_flash_default"] forState:UIControlStateNormal];
        [super.flashButton setImage:[UIImage imageNamed:@"ic_flash_select"] forState:UIControlStateSelected];
        [super.flashButton setImage:[UIImage imageNamed:@"ic_flash_select"] forState:UIControlStateHighlighted];
        
        //        [super.flashButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) + padding * 0.5, topBarHeight - 24 - padding, 24, 24 }];
        [super.flashButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) + 12 + padding, topBarHeight - 24 - padding, 24, 24 }];
    }
    
    return super.flashButton;
}

- (UIButton *) cameraButton
{
    if ( super.cameraButton ) {
        [super.cameraButton setBackgroundColor:[UIColor clearColor]];
        [super.cameraButton setImage:[UIImage imageNamed:@"ic_camera_switch"] forState:UIControlStateNormal];
        [super.cameraButton setImage:[UIImage imageNamed:@"ic_camera_switch"] forState:UIControlStateSelected];
        
        [super.cameraButton setFrame:(CGRect){ CGRectGetWidth(self.bounds) - 35 - padding, topBarHeight  - 35 - padding / 2, 35, 35 }];
    }
    
    return super.cameraButton;
}

- (UIButton *) triggerButton
{
    if ( super.triggerButton ) {
        [super.triggerButton setBackgroundColor:[UIColor clearColor]];
        [super.triggerButton setImage:[UIImage imageNamed:@"ic_camera_shuter"] forState:UIControlStateNormal];
        [super.triggerButton setFrame:(CGRect){ 0, 0, 54, 54 }];
        [super.triggerButton.layer setCornerRadius:27];
        [super.triggerButton setCenter:(CGPoint){ CGRectGetMidX(bottomContainerBar.bounds), bottomBarHeight / 2.0}];
    }
    
    return super.triggerButton;
}

- (UIButton *) photoLibraryButton
{
    if ( super.photoLibraryButton ) {
        [super.photoLibraryButton setFrame:(CGRect){ 37, (bottomBarHeight - 44) / 2.0, 44, 44 }];
    }
    
    return super.photoLibraryButton;
}

- (void) close
{
    if ( [self.delegate respondsToSelector:@selector(closeCamera)] )
        [self.delegate closeCamera];
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !focusBox ) {
        focusBox = [[CALayer alloc] init];
        [focusBox setCornerRadius:45.0f];
        [focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [focusBox setBorderWidth:5.f];
        [focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
        [focusBox setOpacity:0];
    }
    
    return focusBox;
}

- (CALayer *) exposeBox
{
    if ( !exposeBox ) {
        exposeBox = [[CALayer alloc] init];
        [exposeBox setCornerRadius:55.0f];
        [exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
        [exposeBox setBorderWidth:5.f];
        [exposeBox setBorderColor:[[UIColor redColor] CGColor]];
        [exposeBox setOpacity:0];
    }
    
    return exposeBox;
}

#pragma mark - Gestures

- (void) createGesture
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToFocus: )];
    [singleTap setDelaysTouchesEnded:NO];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToExpose: )];
    [doubleTap setDelaysTouchesEnded:NO];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void) tapToFocus:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [self.delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(self.previewLayer.frame, tempPoint) ) {
        [self.delegate cameraView:self focusAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(self.previewLayer.frame) }];
        [self drawFocusBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

- (void) tapToExpose:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [self.delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(self.previewLayer.frame, tempPoint) ) {
        [self.delegate cameraView:self exposeAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(self.previewLayer.frame) }];
        [self drawExposeBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

@end
