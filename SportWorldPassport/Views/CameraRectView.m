//
//  CameraRectView.m
//  SportWorldPassport
//
//  Created by star on 12/10/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CameraRectView.h"

@implementation CameraRectView

- (void) _setup
{
    self.backgroundColor = [UIColor clearColor];
    self.lineWidth = 1.0;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _setup];
    }
    return self;
}

// -------------------------------------------------------------------------------
// Used for drawing the grids ontop of the view port
// -------------------------------------------------------------------------------
- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // calculate top, bottom padding
    CGSize size = self.frame.size;
    CGFloat padding = (size.height - size.width) / 2.0;
    
    // fill space with black color with alpha 0.5
    CGContextSetRGBFillColor(context, 0.f, 0.f, 0.f, 0.5f);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, padding));
    CGContextFillRect(context, CGRectMake(0, size.width + padding, size.width, padding));
    
    // ---------------------------
    // Drawing column lines
    // ---------------------------
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextMoveToPoint(context, 0, padding);
    CGContextAddLineToPoint(context, size.width, padding);
    CGContextAddLineToPoint(context, size.width, size.width + padding);
    CGContextAddLineToPoint(context, 0, size.width + padding);
    CGContextAddLineToPoint(context, 0, padding);
    CGContextStrokePath(context);
}

@end
