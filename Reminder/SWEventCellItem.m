//
//  SWEventCellItem.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWEventCellItem.h"

@implementation SWEventCellItem
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:(NSInteger)self.repeatType forKey:@"repeatType"];
    [aCoder encodeBool:self.alreadyFinished forKey:@"alreadyFinished"];
    [aCoder encodeObject:self.finishedDate forKey:@"finishedDate"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.repeatType = (RepeatType)[aDecoder decodeIntegerForKey:@"repeatType"];
    self.alreadyFinished = [aDecoder decodeBoolForKey:@"alreadyFinished"];
    self.finishedDate = [aDecoder decodeObjectForKey:@"finishedDate"];
    return self;
}
-(id)init
{
    self = [super init];
    self.cellType = TABLE_CELL_EVENT;
    self.identifier = [NSUUID UUID].UUIDString;
    return self;
}
-(id)initWithRecord:(CKRecord*)record
{
    self = [super init];
    self.cellType = TABLE_CELL_EVENT;
    self.identifier = record[@"identifier"];
    self.eventDate = record[@"eventDate"];
    self.eventDescription = record[@"eventDescription"];
    NSNumber* type = record[@"repeatType"];
    self.repeatType = (RepeatType)type.integerValue;
    self.alreadyFinished = ((NSNumber*)(record[@"alreadyFinished"])).boolValue;
    self.finishedDate = record[@"finishedDate"];
    return self;
}
-(BOOL)autoFixAlreadyFinishedVariant
{
    if (self.alreadyFinished&&self.repeatType!=rtNever) {
        NSDate* nextDate = [self normalNextEventDate];
        if (![nextDate isTotay]) {
            NSDate* now  = [NSDate date];
            NSDate* previousDate = nil;
            switch (self.repeatType) {
                case rtWeek:
                    previousDate = [nextDate dateByAddingTimeInterval:-7*24*3600];
                    break;
                case rtMonth:
                    previousDate = [nextDate previousMonth];
                    break;
                case rtYear:
                    previousDate = [nextDate previousYear];
                default:
                    break;
            }
            
            NSComparisonResult cr1 = [self.finishedDate compare:previousDate];
            NSComparisonResult cr2 = [previousDate compare:now];
            if ((cr1==NSOrderedAscending||[self.finishedDate isSameDay:previousDate]) && cr2==NSOrderedAscending) {
                self.finishedDate = nil;
                self.alreadyFinished = NO;
                return YES;
            }
        }

    }
    
    return NO;
}
-(NSDate*)normalNextEventDate
{
    NSDate* newDate = nil;
    
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: self.eventDate];
    
    switch (self.repeatType) {
        case rtWeek:
        {
            NSDate* date = [NSDate date];
            NSDateComponents* today = [date dateComponents];
            //过期了
            if ([self.eventDate compare:date]  == NSOrderedAscending && ![self.eventDate isTotay]) {
                newDate = [gregorianClendar dateWithEra:components.era year:today.year month:today.month day:today.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
                if (today.weekday > components.weekday) {
                    newDate = [newDate dateByAddingTimeInterval:(7-today.weekday+components.weekday)*24*3600];
                }
                else if (today.weekday < components.weekday){
                    newDate = [newDate dateByAddingTimeInterval:(components.weekday-today.weekday)*24*3600];
                }
            }
            else{
                newDate = self.eventDate;
            }
            
            
        }
            break;
        case rtMonth:
        {
            NSDate* date = [NSDate date];
            NSDateComponents* today = [date dateComponents];

            newDate = [gregorianClendar dateWithEra:components.era year:today.year month:today.month day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
            if ([newDate compare:date] == NSOrderedAscending && (components.day!=today.day))//past
            {
                if (today.month < 12) {
                    newDate = [gregorianClendar dateWithEra:components.era year:today.year month:today.month+1 day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
                }
                else{
                    newDate = [gregorianClendar dateWithEra:components.era year:today.year+1 month:1 day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
                }
            }
        }
            break;
        case rtYear:
            newDate = [gregorianClendar dateWithEra:components.era year:[NSDate thisYear] month:components.month day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
            
            if ([newDate compare:[NSDate date]] == NSOrderedAscending&&![newDate isTotay]) {
                newDate = [gregorianClendar dateWithEra:components.era year:[NSDate thisYear]+1 month:components.month day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:0];
            }
            
            
            break;
        default:
            newDate = self.eventDate;
            break;
    }
    
    return newDate;
}
-(BOOL)dateExpired
{
    if (self.repeatType==rtNever) {
        return [self.eventDate compare:[NSDate date]] == NSOrderedAscending;
    }
    
    return NO;
}
-(NSDate*)nextEventDate
{
    NSDate* date = [self normalNextEventDate];
    if (self.alreadyFinished) {
        switch (self.repeatType) {
            case rtWeek:
                date = [date dateByAddingTimeInterval:7*24*3600];
                break;
            case rtMonth:
            {
                NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
                NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
                NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: date];
                if (components.month < 12) {
                    date = [gregorianClendar dateWithEra:components.era year:components.year month:components.month+1 day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:components.nanosecond];
                }
                else{
                    date = [gregorianClendar dateWithEra:components.era year:components.year+1 month:1 day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:components.nanosecond];
                }
            }
                break;
            case rtYear:
            {
                NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];/*公历*/
                NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
                NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: date];
                
                date = [gregorianClendar dateWithEra:components.era year:components.year+1 month:components.month day:components.day hour:components.hour minute:components.minute second:components.second nanosecond:components.nanosecond];
            }
                break;
            default:
                date = self.finishedDate;
                break;
        }
    }
    
    return date;
}
-(NSDate*)nextFireDate
{
    return [self nextEventDate];
}
@end
