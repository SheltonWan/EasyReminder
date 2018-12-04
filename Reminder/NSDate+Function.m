//
//  NSDate+Function.m
//  Reminder
//
//  Created by Shelton on 8/13/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "NSDate+Function.h"

@implementation NSDate (Function)
+(NSDateComponents*)dateComponentsFromDate:(NSDate*)date
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay| NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    return [gregorianClendar components:unitFlags fromDate: date];
}
-(NSDateComponents*)dateComponents
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitEra | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay| NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    return [gregorianClendar components:unitFlags fromDate: self];
}
+(NSDate*)zeroSecondsFromDate:(NSDate*)date
{
    NSDateComponents* cp = [NSDate dateComponentsFromDate:date];
    cp.second = 0;
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: date];
    
    
    return [gregorianClendar dateWithEra:components.era year:components.year month:components.month day:components.day hour:components.hour minute:components.minute second:0 nanosecond:0];
}
+(NSUInteger)thisYear
{
    NSDate* date = [NSDate date];
    NSDateComponents* comp = [date dateComponents];
    return comp.year;
}
+(NSUInteger)thisMonth
{
    NSDate* date = [NSDate date];
    NSDateComponents* comp = [date dateComponents];
    return comp.month;
}
+(NSDate*)nextYearFromDate:(NSDate*)date withHour:(NSInteger)hour
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: date];
    
    
    NSDate* newDate = [gregorianClendar dateWithEra:components.era year:[NSDate thisYear] month:components.month day:components.day hour:23 minute:59 second:59 nanosecond:999];
    
    if ([newDate compare:[NSDate date]] == NSOrderedAscending) {
        newDate = [gregorianClendar dateWithEra:components.era year:[NSDate thisYear]+1 month:components.month day:components.day hour:hour minute:0 second:0 nanosecond:0];
    }
    else{
        newDate = [gregorianClendar dateWithEra:components.era year:[NSDate thisYear] month:components.month day:components.day hour:hour minute:0 second:0 nanosecond:0];
    }
    
    return newDate;
}

+(NSInteger)leftDaysToDate:(NSDate*)date
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* now = [gregorianClendar components:unitFlags fromDate: [NSDate date]];
    NSDateComponents* thatDay = [gregorianClendar components:unitFlags fromDate: date];
    
    NSDate* nowDate = [gregorianClendar dateWithEra:now.era year:now.year month:now.month day:now.day hour:0 minute:0 second:0 nanosecond:0];
    NSDate* thatDate = [gregorianClendar dateWithEra:thatDay.era year:thatDay.year month:thatDay.month day:thatDay.day hour:0 minute:0 second:0 nanosecond:0];
    
    NSTimeInterval distance = [thatDate timeIntervalSinceDate:nowDate];
    
    return floor(distance/(3600*24));
}
-(BOOL)isTotay
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* thatComponents = [gregorianClendar components:unitFlags fromDate: self];
    NSDateComponents* thisComponents = [gregorianClendar components:unitFlags fromDate: [NSDate date]];
    
    return thatComponents.year==thisComponents.year&&thatComponents.month==thisComponents.month&&thatComponents.day==thisComponents.day;
}

- (NSDate *)dateWithEra:(NSInteger)eraValue year:(NSInteger)yearValue month:(NSInteger)monthValue day:(NSInteger)dayValue hour:(NSInteger)hourValue minute:(NSInteger)minuteValue second:(NSInteger)secondValue nanosecond:(NSInteger)nanosecondValue
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    return [gregorianClendar dateWithEra:eraValue year:yearValue month:monthValue day:dayValue hour:hourValue minute:minuteValue second:secondValue nanosecond:nanosecondValue];
}
- (NSDate*)previousMonth
{
    NSDateComponents* dc = [self dateComponents];
    if (dc.month>1) {
        return [self dateWithEra:dc.era year:dc.year month:dc.month-1 day:dc.day hour:dc.hour minute:dc.minute second:dc.second nanosecond:dc.nanosecond];
    }
    else{
        return [self dateWithEra:dc.era year:dc.year-1 month:12 day:dc.day hour:dc.hour minute:dc.minute second:dc.second nanosecond:dc.nanosecond];
    }
}
- (NSDate*)previousYear
{
    NSDateComponents* dc = [self dateComponents];
    return [self dateWithEra:dc.era year:dc.year-1 month:dc.month day:dc.day hour:dc.hour minute:dc.minute second:dc.second nanosecond:dc.nanosecond];
}
-(BOOL)isSameDay:(NSDate*)date
{
    NSDateComponents* dc1 = [self dateComponents];
    NSDateComponents* dc2 = [date dateComponents];
    return dc1.year==dc2.year&&dc1.month==dc2.month&&dc1.day==dc2.day;
}
@end
