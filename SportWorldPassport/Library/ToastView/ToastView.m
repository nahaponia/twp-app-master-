//
//  ToastView.m
//  baccarat
//
//  Created by Race It Home on 5/28/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import "ToastView.h"
#import <QuartzCore/QuartzCore.h>


#define TOAST_GRAVITY_TOP 0
#define TOAST_GRAVITY_BOTTOM 1
#define TOAST_GRAVITY_CENTER 2



@implementation ToastView


- (id)init:(NSString *)_message durationTime:(int)time
{
    self = [super init];
    if (self) {
        timeInterval = time;
        message = _message;
        gravity = TOAST_GRAVITY_BOTTOM;
        offset_left = 0;
        offset_top = 0;
        isRunning = false;
    }

    return self;
}


- (void)setGravity:(int)_gravity offsetLeft:(int)offsetLeft offsetTop:(int)offsetTop
{
    gravity = _gravity;
    offset_left = offsetLeft;
    offset_top = offsetTop;
}


- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    float width = window.frame.size.width;
    float height = window.frame.size.height;

    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *attr = @{ NSFontAttributeName:font};
    CGSize textSize = [message sizeWithAttributes:attr];
    CGRect textRect;
    int label_line_count = 1;
    double max_width = width - 20;
    if (textSize.width <= max_width) {
        textRect = CGRectMake(5, 5, textSize.width + 5, textSize.height + 5);
    } else {
        label_line_count = floor(textSize.width/max_width) + 1;
        textRect = CGRectMake(5, 5, max_width, (textSize.height + 5) * label_line_count);
    }

    UILabel *label = [[UILabel alloc] initWithFrame:textRect];
    [label setNumberOfLines:label_line_count];
    //[label setTextAlignment:UITextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:font];
    [label setText:message];
    [label setShadowColor:[UIColor darkGrayColor]];
    [label setShadowOffset:CGSizeMake(1, 1)];

    UIView *v = [[UIView alloc] init];
    v.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    v.layer.cornerRadius = 10.0;
    v.layer.shadowColor = [UIColor grayColor].CGColor;
    v.layer.shadowOpacity = 0.8;
    v.layer.shadowRadius = 2.0;
    v.layer.shadowOffset = CGSizeMake( 2.0, 2.0);
    v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    v.frame = CGRectMake(0, 0, label.frame.size.width + 10, label.frame.size.height + 10);
    [v addSubview:label];

    CGPoint point;

    // orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            if (gravity == TOAST_GRAVITY_TOP) {
                point = CGPointMake(width/2, 45);
            } else if (gravity == TOAST_GRAVITY_BOTTOM) {
                point = CGPointMake(width/2, height-45);
            } else {
                point = CGPointMake(width/2, height/2);
            }
            point = CGPointMake(point.x - offset_left, point.y - offset_top);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            v.transform = CGAffineTransformMakeRotation(M_PI);
            if (gravity == TOAST_GRAVITY_TOP) {
                point = CGPointMake(width/2, height - 45);
            } else if (gravity == TOAST_GRAVITY_BOTTOM) {
                point = CGPointMake(width/2, 45);
            } else {
                point = CGPointMake(width/2, height/2);
            }
            point = CGPointMake(point.x - offset_left, point.y - offset_top);
            break;
        case UIDeviceOrientationLandscapeLeft:
            v.transform = CGAffineTransformMakeRotation(M_PI_2);
            if (gravity == TOAST_GRAVITY_TOP) {
                point = CGPointMake(width - 45, height/2);
            } else if (gravity == TOAST_GRAVITY_BOTTOM) {
                point = CGPointMake(45, height/2);
            } else {
                point = CGPointMake(width/2, height/2);
            }
            point = CGPointMake(point.x - offset_left, point.y - offset_top);
            break;
        case UIDeviceOrientationLandscapeRight:
            v.transform = CGAffineTransformMakeRotation(-M_PI_2);
            if (gravity == TOAST_GRAVITY_TOP) {
                point = CGPointMake(45, height/2);
            } else if (gravity == TOAST_GRAVITY_BOTTOM) {
                point = CGPointMake(width-45, height/2);
            } else {
                point = CGPointMake(width/2, height/2);
            }
            point = CGPointMake(point.x - offset_left, point.y - offset_top);
            break;
            
        default:
            point = CGPointMake(width/2 + offset_left, height/2 + offset_top);
            break;
    }

    v.center = point;
    [window addSubview:v];
    [window bringSubviewToFront:v];
    view = v;
    [self performSelector:@selector(hideToast) withObject:nil afterDelay:timeInterval];
    isRunning = true;
}


- (bool)isRun
{
    return isRunning;
}


- (UIView *)view
{
    return view;
}


- (void)hideToast
{
    if (isRunning && view != nil) {
        [UIView beginAnimations:@"" context:nil];
        view.alpha = 0;
        [UIView commitAnimations];
    }

    //isRunning = false;

    if (isRunning && view != nil) {
        isRunning = false;
        [view removeFromSuperview];
    }
}


+ (void)showToast:(NSString *)message durationTime:(int)time
{
    ToastView *toastView = [[ToastView alloc] init:message durationTime:time];
    [toastView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

@end
