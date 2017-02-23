//
//  LoadingView.h
//  SportWorldPassport
//
//  Created by star on 12/1/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic, assign) float total;
@property (nonatomic, assign) float current;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIColor* mainColor;
@property (nonatomic, retain) UIColor* backColor;
@property (nonatomic, assign) BOOL timerMode;

- (void)initWithTotal:(float)total TimerMode:(BOOL)timerMode Delegate:(id)delegate;
- (void)start;
- (void)stop;
- (void)accelerate;

@end
