//
//  InputView.m
//  SportWorldPassport
//
//  Created by star on 7/7/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "InputView.h"

@implementation InputView

- (id)init {
    self = [super init];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (void)setUISettings {
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    
//    self.layer.borderColor = COLOR_GRAY_LIGHT.CGColor;
    self.layer.borderWidth = 1;
    
//    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setBgColor:(UIColor *)color {
    [self setBackgroundColor:color];
}

@end
