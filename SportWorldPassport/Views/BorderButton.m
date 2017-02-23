//
//  BorderButton.m
//  SportWorldPassport
//
//  Created by star on 7/7/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "BorderButton.h"

@implementation BorderButton

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
    self.layer.cornerRadius = 4;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
    
    UIColor *titleColor = self.currentTitleColor;
    self.layer.borderColor = titleColor.CGColor;
}

- (void)setBorderColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
}

- (void)setCornerRadius:(float)radius {
    self.layer.cornerRadius = radius;
}

- (void)setNormalStateColor:(UIColor *)color {
//    [self setBackgroundImage:[CommonUtils imageWithColor:color] forState:UIControlStateNormal];
}

- (void)setSelectedStateColor:(UIColor *)color {
//    [self setBackgroundImage:[CommonUtils imageWithColor:color] forState:UIControlStateSelected|UIControlStateHighlighted];
}

@end
