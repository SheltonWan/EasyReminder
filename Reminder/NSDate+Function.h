//
//  NSDate+Function.h
//  Reminder
//
//  Created by Shelton on 8/13/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Function)
-(NSDateComponents*)dateComponents;
+(NSDate*)nextYearFromDate:(NSDate*)date  withHour:(NSInteger)hour;//周年
+(NSInteger)leftDaysToDate:(NSDate*)date;
+(NSDate*)zeroSecondsFromDate:(NSDate*)date;
+(NSUInteger)thisYear;
+(NSUInteger)thisMonth;
-(BOOL)isTotay;
- (NSDate *)dateWithEra:(NSInteger)eraValue year:(NSInteger)yearValue month:(NSInteger)monthValue day:(NSInteger)dayValue hour:(NSInteger)hourValue minute:(NSInteger)minuteValue second:(NSInteger)secondValue nanosecond:(NSInteger)nanosecondValue;
- (NSDate*)previousMonth;
- (NSDate*)previousYear;
-(BOOL)isSameDay:(NSDate*)date;
@end
