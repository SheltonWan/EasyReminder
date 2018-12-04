//
//  UITableCellView.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCellItem.h"


@interface UITableCellView : UIView

@property (assign) TABLE_CELL_TYPE cellType;
@property (assign) BOOL         isToday;
@property (retain) UIImage*     face;
@property (copy)  NSString *    name;
@property (copy)  NSString *    eventTitle;
@property (copy)  NSString *    dateLabel;
@property (retain)  NSDate*     displayDate;
@property (assign) NSInteger     ages;
@property (assign) NSInteger     leftDays;


@property (nonatomic, getter=isSelected) BOOL         selected;
@end


