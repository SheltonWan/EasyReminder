//
//  SWCellItem.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWCellItem.h"

@implementation SWCellItem

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:(NSInteger)self.cellType forKey:@"cellType"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.givenName forKey:@"givenName"];
    [aCoder encodeObject:self.familyName forKey:@"familyName"];
    [aCoder encodeObject:self.imageData forKey:@"imageData"];
    [aCoder encodeObject:self.thumbnailImageData forKey:@"thumbnailImageData"];
    [aCoder encodeObject:self.eventDate forKey:@"eventDate"];
    [aCoder encodeObject:self.dateComponents forKey:@"dateComponents"];
    [aCoder encodeObject:self.eventDescription forKey:@"eventDescription"];

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.cellType = (TABLE_CELL_TYPE)[aDecoder decodeIntegerForKey:@"cellType"];
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    self.givenName = [aDecoder decodeObjectForKey:@"givenName"];
    self.familyName = [aDecoder decodeObjectForKey:@"familyName"];
    self.imageData = [aDecoder decodeObjectForKey:@"imageData"];
    self.thumbnailImageData = [aDecoder decodeObjectForKey:@"thumbnailImageData"];
    self.eventDate = [aDecoder decodeObjectForKey:@"eventDate"];
    self.dateComponents = [aDecoder decodeObjectForKey:@"dateComponents"];
    self.eventDescription = [aDecoder decodeObjectForKey:@"eventDescription"];

    
    return self;
}

-(BOOL) isToday:(NSDate*)fireDate
{
    NSDateFormatter *kDateFormatter = [[NSDateFormatter alloc] init];
    [kDateFormatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString* fireDateString = [kDateFormatter stringFromDate:fireDate];
    NSString* todayString = [kDateFormatter stringFromDate:[NSDate date]];
    
    return [[todayString substringToIndex:8] compare:[fireDateString substringToIndex:8]] == NSOrderedSame;
}

-(NSDate*)nextEventDate
{
    return nil;
}
-(NSDate*)nextFireDate
{
    return nil;
}
-(NSInteger)ages
{
    NSDateComponents* birth = [self.eventDate dateComponents];
    NSDateComponents* nextBirth = [[self nextEventDate] dateComponents];
    
    return nextBirth.year - birth.year;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@:%@",self.familyName,self.givenName,self.eventDate];
}

-(BOOL)dateExpired
{
    return NO;
}
@end
