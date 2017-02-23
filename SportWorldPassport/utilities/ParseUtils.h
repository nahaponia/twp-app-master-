//
//  ParseUtils.h
//  SportWorldPassport
//
//  Created by star on 10/30/15.
//  Copyright (c) 2015 com.UWP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseUtils : NSObject

+ (void)setParsePictureOf:(UIImageView *)imageView file:(PFFile *)pFile default:(NSString *)name;

+ (void)sendPushOfShow:(PFObject *)showObject from:(NSDate *)date;

+ (void)likeFeed:(PFObject *)feed like:(BOOL)like withView:(UIView *) view;

+ (void)sendParseEmail:(NSString *)to from:(NSString *)from message:(NSString *)message;
+ (void)sendParseEmailWithTemplate:(NSString *)templateName to:(NSString *)to from:(NSString *)from message:(NSDictionary *)message;

@end

