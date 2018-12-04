//
//  UINavigationControllerEx.m
//  Reminder
//
//  Created by Shelton on 8/23/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UINavigationControllerEx.h"
#import "ReminderData.h"
@interface UINavigationControllerEx ()

@end

@implementation UINavigationControllerEx
//View controller-based status bar appearance set YES
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[ReminderData defaultData] test];
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
