//
//  EventDetailViewController.h
//  Reminder
//
//  Created by Shelton on 8/30/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWEventCellItem.h"
@interface EventDetailViewController : UIViewController
@property(retain) NSDate* eventDate;
@property(retain,readonly) SWEventCellItem* item;
+(id)viewControllerWithItem:(SWCellItem*)item;
@end
