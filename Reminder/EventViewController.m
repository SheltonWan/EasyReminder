//
//  EventViewController.m
//  Reminder
//
//  Created by Shelton on 8/30/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(TABLE_CELL_TYPE)tableCellType
{
    return TABLE_CELL_EVENT;
}
- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"Event view appear...");
}
- (void)viewDidDisappear:(BOOL)animated
{
//    NSLog(@"Event view disappear...");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
