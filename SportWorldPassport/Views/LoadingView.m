//
//  LoadingView.m
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "LoadingView.h"

#define LOADING_COLOR_MAIN       [UIColor colorWithRed:16/255.0 green:151/255.0 blue:1.0 alpha:1.0]

@interface LoadingView()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) float step;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LoadingView

@synthesize timer;
@synthesize running;
@synthesize step;
@synthesize total;
@synthesize current;
@synthesize delegate;
@synthesize mainColor;
@synthesize backColor;
@synthesize timerMode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}


- (void)initWithTotal:(float)_total TimerMode:(BOOL)_timerMode Delegate:(id)_delegate
{
    self.total = _total;
    self.timerMode = _timerMode;
    self.delegate = _delegate;
}


- (void)initialize
{
    total = 5; // 5 seconds
    step = 0.01;
    current = 0;
    mainColor = LOADING_COLOR_MAIN;
    backColor = [UIColor clearColor];
    timerMode = true;
    self.backgroundColor = [UIColor clearColor];
}


- (void)start
{
    [self startWithCurrent:0];
}


- (void)startWithCurrent:(float)curvalue
{
    if (curvalue >= 0) {
        running = NO;
        current = curvalue;
        timer = [NSTimer scheduledTimerWithTimeInterval:step target:self selector:@selector(updateCircle:) userInfo:nil repeats:YES];
    }
}

- (void)accelerate {
    float left = total - current;
    if (left > total / 2.0) {
        step *= 4.0;
    } else if (left > 3) {
        step *= 3.0;
    } else if (left > 2) {
        step *= 2.0;
    } else if (left > 1) {
        step *= 1.5;
    }
}

- (void)stop
{
    [timer invalidate];
}


- (void)drawRect:(CGRect)rect
{
    float percent = [self worthToRun] ? current / total : 1.0;
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width * percent, height)];
    [mainColor setFill];
//    fillPath.lineWidth = height;
    [fillPath fill];
}


- (void)updateCircle:(NSTimer *)theTimer
{
    if (![self worthToRun]) {
        running = NO;
        [timer invalidate];
        [self setNeedsDisplay];
        if (delegate && [delegate respondsToSelector:@selector(timerFinished:)]) {
            [delegate performSelectorOnMainThread:@selector(timerFinished:) withObject:self waitUntilDone:NO];
        }
    } else {
        if (timerMode)
            current += step;
        running = YES;
        [self setNeedsDisplay];
    }
}


- (BOOL)worthToRun
{
    return (total >= current);
}


@end
