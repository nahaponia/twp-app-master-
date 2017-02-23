//
//  RoundButton.m
//  SportWorldPassport
//
//  Created by star on 11/26/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

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
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.clipsToBounds = YES;
}

@end
