//
//  SWAnniversaryCellItem.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWAnniversaryCellItem.h"

@implementation SWAnniversaryCellItem

+(instancetype)itemWithContact:(CNContact *) contact  label:(CNLabeledValue*)value
{
    SWAnniversaryCellItem* item = [SWAnniversaryCellItem new];
    item.givenName = contact.givenName;
    item.familyName = contact.familyName;

    item.imageData = contact.imageData;
    item.thumbnailImageData = contact.thumbnailImageData;
    
    item.label = [CNLabeledValue localizedStringForLabel:value.label];
    item.dateComponents = value.value;
    item.eventDate = item.dateComponents.date;
    item.cellType = TABLE_CELL_ANNIVERSARY;
    item.identifier = contact.identifier;
    return item;
}

+(instancetype)itemWithGivenName:(NSString*)givenName familyName:(NSString*)familyName eventDate:(NSDateComponents*)dateComponent label:(NSString*)label thumbnail:(NSData*)thumbnailData
{
    SWAnniversaryCellItem* item = [SWAnniversaryCellItem new];
    item.givenName = givenName;
    item.familyName = familyName;
    item.thumbnailImageData = thumbnailData;
    
    item.label = label;
    item.dateComponents = dateComponent;
    item.eventDate = dateComponent.date;
    item.cellType = TABLE_CELL_ANNIVERSARY;
    return item;
}

-(NSDate*)nextEventDate
{
    return [NSDate nextYearFromDate:self.eventDate withHour:0];
}

-(NSDate*)nextFireDate
{
    return [NSDate nextYearFromDate:self.eventDate withHour:12];
}
@end
