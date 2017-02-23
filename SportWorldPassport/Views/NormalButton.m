//
//  NormalButton.m
//  SportWorldPassport
//
//  Created by star on 7/7/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "NormalButton.h"

@implementation NormalButton

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
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    /*
    UIColor *bgColor = [self backgroundColor];
    
    // extract r, g, b color values
    const CGFloat* components = CGColorGetComponents( bgColor.CGColor );
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];
    
    [self setBackgroundImage:[CommonUtils imageWithColor:bgColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[CommonUtils imageWithColor:[UIColor colorWithRed:red green:green blue:blue alpha:alpha * 0.8]] forState:UIControlStateDisabled];
    [self setBackgroundColor:[UIColor clearColor]];
     */
}

- (void)setNormalStateColor:(UIColor *)color {
    //    [self setBackgroundImage:[CommonUtils imageWithColor:color] forState:UIControlStateNormal];
}

- (void)setSelectedStateColor:(UIColor *)color {
    //    [self setBackgroundImage:[CommonUtils imageWithColor:color] forState:UIControlStateSelected|UIControlStateHighlighted];
}

@end
