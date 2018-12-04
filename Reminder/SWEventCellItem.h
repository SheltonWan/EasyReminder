//
//  SWEventCellItem.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "SWCellItem.h"
#import <CloudKit/CloudKit.h>
@interface SWEventCellItem : SWCellItem
@property(assign) RepeatType repeatType;
@property (assign)  BOOL            alreadyFinished;
@property (retain)  NSDate*         finishedDate;

-(BOOL)autoFixAlreadyFinishedVariant;

-(id)initWithRecord:(CKRecord*)record;
@end
