//
//  UITableViewControllerEx.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCellItem.h"
@interface UITableViewControllerEx : UITableViewController
@property (assign)  TABLE_CELL_TYPE cellType;
@property(nonatomic,assign) UINavigationBar *navigationBar;
-(void)addItem:(SWCellItem*)item;
@end
