//
//  SWBirthCellItem.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWCellItem.h"

@interface SWBirthCellItem : SWCellItem
@property(assign) BOOL inLunar;

+(instancetype)itemWithContact:(CNContact *) contact;
+(instancetype)itemWithLunarContact:(CNContact *) contact;
+(instancetype)itemWithGivenName:(NSString*)givenName familyName:(NSString*)familyName birthday:(NSDateComponents*)dateComponents image:(NSData*)imageData thumbnail:(NSData*)thumbnailData;

-(void)updateItemWithContact:(CNContact*)contact;
@end
