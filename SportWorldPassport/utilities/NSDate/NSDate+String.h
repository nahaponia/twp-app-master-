//
//  NSDate+String.h
//  EverAfter
//
//  Created by Donald Pae on 12/09/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (String)

- (NSString *)toStringWithFormat:(NSString *)format;
+ (NSDate *)dateWithString:(NSString *)strDate withFormat:(NSString *)format;

@end
