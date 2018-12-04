//
//  SWBirthCellItem.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWBirthCellItem.h"

@implementation SWBirthCellItem

+(instancetype)itemWithContact:(CNContact *) contact
{
    SWBirthCellItem* item = [SWBirthCellItem new];
    item.givenName = contact.givenName;
    item.familyName = contact.familyName;
    item.dateComponents = contact.birthday;
    item.imageData = contact.imageData;
    item.thumbnailImageData = contact.thumbnailImageData;
    
    item.eventDate = contact.birthday.date;
    item.cellType = TABLE_CELL_BIRTHDAY;
    item.identifier = contact.identifier;
    return item;
}
+(instancetype)itemWithLunarContact:(CNContact *) contact
{
    SWBirthCellItem* item = [SWBirthCellItem new];
    item.givenName = contact.givenName;
    item.familyName = contact.familyName;
    item.dateComponents = contact.nonGregorianBirthday;
    item.imageData = contact.imageData;
    item.thumbnailImageData = contact.thumbnailImageData;
    
    item.eventDate = contact.nonGregorianBirthday.date;
    item.cellType = TABLE_CELL_BIRTHDAY_LUNAR;
    item.identifier = contact.identifier;
    item.inLunar = YES;
    return item;
}

-(void)updateItemWithContact:(CNContact*)contact
{
    self.givenName = contact.givenName;
    self.familyName = contact.familyName;
    self.imageData = contact.imageData;
    self.thumbnailImageData = contact.thumbnailImageData;
    self.identifier = contact.identifier;
    if (self.inLunar) {
        if (contact.nonGregorianBirthday) {
           
            self.dateComponents = contact.nonGregorianBirthday;
            self.eventDate = contact.nonGregorianBirthday.date;
            self.cellType = TABLE_CELL_BIRTHDAY_LUNAR;
            self.inLunar = YES;
        }
        else if(contact.birthday)
        {
            self.dateComponents = contact.birthday;
            self.eventDate = contact.birthday.date;
            self.cellType = TABLE_CELL_BIRTHDAY;
            self.inLunar = NO;
        }
    }
    else{
        if (contact.birthday) {
            self.dateComponents = contact.birthday;
            self.eventDate = contact.birthday.date;
            self.cellType = TABLE_CELL_BIRTHDAY;
        }
        else if (contact.nonGregorianBirthday){
            self.dateComponents = contact.nonGregorianBirthday;
            self.eventDate = contact.nonGregorianBirthday.date;
            self.cellType = TABLE_CELL_BIRTHDAY_LUNAR;
            self.inLunar = YES;
        }
    }
}
+(instancetype)itemWithGivenName:(NSString*)givenName familyName:(NSString*)familyName birthday:(NSDateComponents*)dateComponents image:(NSData*)imageData thumbnail:(NSData*)thumbnailData
{
    SWBirthCellItem* item = [SWBirthCellItem new];
    item.givenName = givenName;
    item.familyName = familyName;
    item.dateComponents = dateComponents;
    item.imageData = imageData;
    item.thumbnailImageData = thumbnailData;
    
    item.eventDate = dateComponents.date;
    item.cellType = TABLE_CELL_BIRTHDAY;
    return item;
}

-(NSDate*)nextEventDate
{
    return [self birthdayWithHour:0];
}
-(NSDate*)nextFireDate
{
    return [self birthdayWithHour:12];
}
-(NSDate*)birthdayWithHour:(NSInteger)hour
{
    NSCalendar* gregorianClendar = [[NSCalendar alloc] initWithCalendarIdentifier:self.dateComponents.calendar.calendarIdentifier];
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [gregorianClendar components:unitFlags fromDate: self.dateComponents.date];
    NSDateComponents* nowComponents = [gregorianClendar components:unitFlags fromDate: [NSDate date]];
    
    NSDate* newDate = [gregorianClendar dateWithEra:nowComponents.era year:nowComponents.year month:components.month day:components.day hour:23 minute:59 second:59 nanosecond:0];
    
    if ([newDate compare:[NSDate date]] == NSOrderedAscending) {
        newDate = [gregorianClendar dateWithEra:nowComponents.era year:nowComponents.year+1 month:components.month day:components.day hour:hour minute:0 second:0 nanosecond:0];
    }
    else{
        newDate = [gregorianClendar dateWithEra:nowComponents.era year:nowComponents.year month:components.month day:components.day hour:hour minute:0 second:0 nanosecond:0];
    }
    
    return newDate;
}

@end
