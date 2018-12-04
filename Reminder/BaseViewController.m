//
//  BaseViewController.m
//  Reminder
//
//  Created by Shelton on 8/15/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "BaseViewController.h"
#import "AppConst.h"
@interface BaseViewController ()
{
    UITableViewControllerEx* _tableViewController;
}
@end

@implementation BaseViewController
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addTableViewController];
    
    //NSLog(@"table size: %f x %f (scale:%f)",rect.size.width,rect.size.height,[UIScreen mainScreen].scale);
}

-(void)addTableViewController
{
    _tableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tableViewController"];
    _tableViewController.navigationBar = self.navigationController.navigationBar;
    _tableViewController.cellType = [self tableCellType];
    CGRect rect = [self tableViewFrame];
    [_tableViewController.view setFrame:rect];
    
//    [self.navigationController pushViewController:tableViewController animated:NO];
    [self addChildViewController:_tableViewController];//必须调用
    [self.view addSubview:_tableViewController.view];
}
-(void)reloadTableView
{
    [_tableViewController.tableView reloadData];
}
-(TABLE_CELL_TYPE)tableCellType
{
    return TABLE_CELL_BIRTHDAY;
}
- (CGRect)tableViewFrame
{
    return CGRectMake(0, 44+NAV_BAR_ORIGN_Y, self.view.frame.size.width, self.view.frame.size.height-44-44-NAV_BAR_ORIGN_Y+2);
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
