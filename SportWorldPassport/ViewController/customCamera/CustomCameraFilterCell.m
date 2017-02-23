//
//  CustomCameraFilterCell.m
//  SportWorldPassport
//
//  Created by star on 12/17/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomCameraFilterCell.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger kLabelHeight = 18;
static const NSUInteger kCellPadding = 10;
static const NSUInteger kBorderWidth = 1;

@implementation CustomCameraFilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *backgroundCellView = [[UIView alloc] initWithFrame:(CGRect){ 0, kBorderWidth, CGRectGetWidth(self.frame)-kBorderWidth, CGRectGetHeight(self.frame)-kBorderWidth*2 }];
        [backgroundCellView setBackgroundColor:[UIColor clearColor]];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kLabelHeight, self.frame.size.width, kLabelHeight-kCellPadding)];
        [_label setFont:[UIFont systemFontOfSize:9]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setTextColor:[UIColor colorWithRed:16/255.0 green:27/255.0 blue:47/255.0 alpha:1.0]];
        [_label setBackgroundColor:[UIColor clearColor]];
        [backgroundCellView addSubview:_label];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, CGRectGetWidth(self.frame)-kCellPadding*2, CGRectGetWidth(self.frame)-kCellPadding*2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView.layer setCornerRadius:_imageView.frame.size.height / 2.0];
        [_imageView.layer setBorderWidth:0.0];
        [_imageView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.3].CGColor];
        [_imageView.layer setMasksToBounds:YES];
        
        [backgroundCellView addSubview:_imageView];
        
        [self addSubview:backgroundCellView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{
    
}

@end
