//
//  SWCellItem.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

#import "NSDate+Function.h"

typedef enum
{
    rtNever = 0,
    rtWeek  = 1,
    rtMonth = 2,
    rtYear = 3
} RepeatType;

typedef enum{
    TABLE_CELL_ALL = 0,
    TABLE_CELL_BIRTHDAY,
    TABLE_CELL_BIRTHDAY_LUNAR,
    TABLE_CELL_EVENT,
    TABLE_CELL_ANNIVERSARY
}TABLE_CELL_TYPE;

@interface SWCellItem : NSObject<NSCoding>
{
    
}
@property (assign)  TABLE_CELL_TYPE cellType;
@property (copy)    NSString *      identifier;
@property (copy)    NSString *      givenName;
@property (copy)    NSString *      familyName;
@property (retain)  NSData *        imageData;
@property (retain)  NSData *        thumbnailImageData;
@property(retain)   NSDateComponents* dateComponents;

@property (retain)  NSDate *        eventDate;
@property (copy)  NSString *        eventDescription;



-(BOOL) isToday:(NSDate*)fireDate;
-(NSDate*)nextEventDate;
-(NSDate*)nextFireDate;
-(NSInteger)ages;
-(BOOL)dateExpired;
@end
