//
//  NSDate+String.m
//  EverAfter
//
//  Created by Donald Pae on 12/09/14.
//
//

#import "NSDate+String.h"

@implementation NSDate (String)

- (NSString *)toStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)dateWithString:(NSString *)strDate withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:strDate];
}

@end
