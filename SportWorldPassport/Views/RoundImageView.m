//
//  RoundImageView.m
//  SportWorldPassport
//
//  Created by star on 7/9/15.
//  Copyright (c) 2015 com.UWP. All rights reserved.
//

#import "RoundImageView.h"

@implementation RoundImageView

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
    self.clipsToBounds = YES;
    
//    self.layer.borderColor = COLOR_YELLOW.CGColor;
    self.layer.borderWidth = 1;
    
}

@end
