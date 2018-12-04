//
//  SWAnniversaryCellItem.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWCellItem.h"

@interface SWAnniversaryCellItem : SWCellItem

@property(copy) NSString* label;
+(instancetype)itemWithContact:(CNContact *) contact  label:(CNLabeledValue*)value;
+(instancetype)itemWithGivenName:(NSString*)givenName familyName:(NSString*)familyName eventDate:(NSDateComponents*)dateComponent label:(NSString*)label thumbnail:(NSData*)thumbnailData;
@end
