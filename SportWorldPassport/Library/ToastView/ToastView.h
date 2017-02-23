//
//  ToastView.h
//  baccarat
//
//  Created by Race It Home on 5/28/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToastView : NSObject
{
    int gravity;
    int offset_left;
    int offset_top;
    int timeInterval;
    NSString *message;
    UIView *view;
    bool isRunning;
}

- (id)init:(NSString *)_message durationTime:(int)time;
- (void)show;
+ (void)showToast:(NSString *)message durationTime:(int)time;

@end
