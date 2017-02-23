//
//  NSDate+Convenience.m
//  FiveStar
//
//  Created by Leon on 13-1-14.
//
//

@implementation NSDate (Convenience)

- (int)year {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:self];
    return (int)[components year];
}


- (int)month {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitMonth fromDate:self];
    return (int)[components month];
}

- (int)day {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:self];
    return (int)[components day];
}

- (int)hour {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitHour fromDate:self];
    return (int)[components hour];
}

- (NSDate *)offsetDay:(int)numDays {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    [gregorian setFirstWeekday:2]; //monday is first day

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];
    //[offsetComponents setHour:1];
    //[offsetComponents setMinute:30];

    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}

- (BOOL)isToday
{
    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
}

+ (NSString *)offsetStringBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    int days = [NSDate daysBetweenStartDate:startDate endDate:endDate];
    if (days > 0) {
        if (days > 30) {
            return [NSString stringWithFormat:@"%d months ago", days%30];
        }
        if (days == 1) {
            return [NSString stringWithFormat:@"%d day ago", days];
        } else {
            return [NSString stringWithFormat:@"%d days ago", days];
        }
    }
    
    int hours = [NSDate hoursBetweenStartDate:startDate endDate:endDate];
    if (hours > 0) {
        if (hours == 1) {
            return [NSString stringWithFormat:@"%d hour ago", hours];
        } else {
            return [NSString stringWithFormat:@"%d hours ago", hours];
        }
    }
    
    int mins = [NSDate minutesBetweenStartDate:startDate endDate:endDate];
    if (mins > 0) {
        if (mins == 1) {
            return [NSString stringWithFormat:@"%d minute ago", mins];
        } else {
            return [NSString stringWithFormat:@"%d minutes ago", mins];
        }
    }
    return @"just now";
}

+ (NSDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    return [gregorian dateFromComponents:components];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components =
            [gregorian               components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                    NSCalendarUnitDay) fromDate:date];
    return [gregorian dateFromComponents:components];
}

- (NSString *)weekString {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:kCFCalendarUnitWeekday fromDate:self];
    switch (dateComponents.weekday) {
        case 1: {
            return NSLocalizedString(@"sunday", @"");
        }
            break;

        case 2: {
            return NSLocalizedString(@"monday", @"");
        }
            break;

        case 3: {
            return NSLocalizedString(@"tuesday", @"");
        }
            break;

        case 4: {
            return NSLocalizedString(@"wednesday", @"");
        }
            break;

        case 5: {
            return NSLocalizedString(@"thursday", @"");
        }
            break;

        case 6: {
            return NSLocalizedString(@"friday", @"");
        }
            break;

        case 7: {
            return NSLocalizedString(@"saturday", @"");
        }
            break;

        default:
            break;
    }

    return @"";
}

+ (int)daysBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate toDate:endDate options:0];
    //    int months = [comps month];
    int days = (int)[comps day];
    return days;
}

+ (int)hoursBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitHour;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate toDate:endDate options:0];
    //    int months = [comps month];
    int hours = (int)[comps hour];
    return hours;
}

+ (int)minutesBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitMinute;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate toDate:endDate options:0];
    //    int months = [comps month];
    int mins = (int)[comps minute];
    return mins;
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!format)
        format = @"MMMM dd, yyyy";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    if (!format)
        format = @"MMMM dd, yyyy";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


+ (NSDate *)dateFromString:(NSString *)dateString {
    return [self dateFromStringBySpecifyTime:dateString hour:0 minute:0 second:0];
}

+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSArray *arrayDayTime = [dateString componentsSeparatedByString:@" "];
    NSArray *arrayDay = [arrayDayTime[0] componentsSeparatedByString:@"-"];

    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *tmpDateComponents = [calendar components:flags fromDate:[NSDate date]];
    tmpDateComponents.year = [arrayDay[0] intValue];
    tmpDateComponents.month = [arrayDay[1] intValue];
    tmpDateComponents.day = [arrayDay[2] intValue];
    if ([arrayDayTime count] > 1) {
        NSArray *arrayTime = [arrayDayTime[1] componentsSeparatedByString:@":"];
        tmpDateComponents.hour = [arrayTime[0] intValue];
        tmpDateComponents.minute = [arrayTime[1] intValue];
        tmpDateComponents.second = [arrayTime[2] intValue];
    }
    else {
        tmpDateComponents.hour = hour;
        tmpDateComponents.minute = minute;
        tmpDateComponents.second = second;
    }
    return [calendar dateFromComponents:tmpDateComponents];
}

+ (NSDateComponents *)nowDateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[NSDate date]];
}

+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[[NSDate date] dateByAddingTimeInterval:days * 24 * 60 * 60]];
}


@end
