//
//  AllItemViewController.m
//  Reminder
//
//  Created by Shelton on 8/15/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "AllItemViewController.h"

@interface AllItemViewController ()

@end

@implementation AllItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(TABLE_CELL_TYPE)tableCellType
{
    return TABLE_CELL_ALL;
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
