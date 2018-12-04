//
//  FirstViewController.m
//  Reminder
//
//  Created by Shelton on 8/3/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "BirthdayViewController.h"

@interface BirthdayViewController ()

@end

@implementation BirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(TABLE_CELL_TYPE)tableCellType
{
    return TABLE_CELL_BIRTHDAY;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
