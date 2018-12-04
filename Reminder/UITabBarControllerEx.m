//
//  UITabBarControllerEx.m
//  Reminder
//
//  Created by Shelton on 8/7/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITabBarControllerEx.h"
#import "AppConst.h"
#import "BaseViewController.h"
#import "EventDetailViewController.h"
#import "SWBirthCellItem.h"
#import "SWAnniversaryCellItem.h"
#import "ReminderData.h"
#import <ContactsUI/ContactsUI.h>

@interface UITabBarControllerEx ()<CNContactViewControllerDelegate,CNContactPickerDelegate>
@property(retain) UISegmentedControl* segmentedControl;
@end

@implementation UITabBarControllerEx
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    for (UITabBarItem* item in self.tabBar.items) {
        //这个可以由图片设置，不需要代码处理
        //item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }

    [self setNavigationBarButton];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    [self createSegmentedControl];
    
}
-(void)createSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"代办事项",@"过去事项", nil]];
    [self.segmentedControl addTarget:self action:@selector(controlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    //self.segmentedControl.tintColor = [UIColor colorWithRed:4/255. green:50/255. blue:78/255. alpha:0.01];
    
    UIImage* image1 = [[UIImage imageNamed:@"segmentBackground_Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage* image2 = [[UIImage imageNamed:@"segmentDiv"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setDividerImage:image2 forLeftSegmentState:UIControlStateNormal
                         rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // Image between segment selected on the left and unselected on the right.
    [self.segmentedControl setDividerImage:image2 forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // Image between segment selected on the right and unselected on the right.
    [self.segmentedControl setDividerImage:image2 forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    CGRect barFrame = self.navigationController.navigationBar.bounds;
    self.segmentedControl.frame = CGRectMake((barFrame.size.width - self.segmentedControl.bounds.size.width)/2, (barFrame.size.height - self.segmentedControl.bounds.size.height)/2, self.segmentedControl.bounds.size.width, self.segmentedControl.bounds.size.height);
    
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}
#pragma mark
-(void)controlEventValueChanged:(id)sender
{
    BaseViewController* viewController =  (BaseViewController*)self.selectedViewController;
    [viewController reloadTableView];

    if (self.segmentedControl.selectedSegmentIndex==1) {
        UIImage* image1 = [[UIImage imageNamed:@"segmentBackground"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }
    else{
        UIImage* image1 = [[UIImage imageNamed:@"segmentBackground_Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.segmentedControl setBackgroundImage:image1 forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.segmentedControl.selectedSegmentIndex forKey:@"selectedSegmentIndex"];
}
#pragma mark
-(void)setNavigationBarButton
{
//    UIImage* image = [[UIImage imageNamed:@"nav_setting_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//
//    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonClick:)];
//    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    
    UIImage* image = [[UIImage imageNamed:@"nav_adding_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(addingButtonClick:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"navigationBar(y:%f,h:%f)",self.navigationController.navigationBar.frame.origin.x,self.navigationController.navigationBar.frame.size.height);
//    self.navigationItem.title = self.tabBar.selectedItem.title;
    
    if (self.tabBar.selectedItem.tag == 3) {
        self.navigationItem.title = @"";
        [self.navigationController.navigationBar addSubview:self.segmentedControl];
        
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSegmentIndex"];
        [self.segmentedControl setSelectedSegmentIndex:index];
        [self controlEventValueChanged:nil];
//        NSLog(@"Tabbar event view appear...");
    }
    else{
        self.navigationItem.title = self.tabBar.selectedItem.title;
        if (self.segmentedControl.superview) {
            [self.segmentedControl removeFromSuperview];
        }
        
    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.tabBar.selectedItem.tag == 3)
    {
        if (self.segmentedControl.superview) {
            [self.segmentedControl removeFromSuperview];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
- (void)settingButtonClick:(id)sender
{

}
- (void)addingButtonClick:(id)sender
{
//    NSLog(@"Adding button click. %@",sender);
    switch (self.tabBar.selectedItem.tag) {
        case 3:
        {
            if (self.segmentedControl.superview) {
                [self.segmentedControl removeFromSuperview];
            }
            
            EventDetailViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
            [self.navigationController pushViewController:viewController animated:YES];

        }
            break;
        case 1:
        {
            CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
            NSArray *propertyKeys = @[CNContactBirthdayKey,  CNContactGivenNameKey, CNContactFamilyNameKey];
            NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"birthday == nil && nonGregorianBirthday == nil"];
            
            picker.displayedPropertyKeys = propertyKeys;
            picker.predicateForEnablingContact = enablePredicate;
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 2:
        {
            CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
            NSArray *propertyKeys = @[CNContactBirthdayKey,  CNContactGivenNameKey, CNContactFamilyNameKey];
            NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"dates.@count == 0"];
            
            picker.displayedPropertyKeys = propertyKeys;
            picker.predicateForEnablingContact = enablePredicate;
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:nil];
            
            
        }
            break;
        default:
        {
            CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
            NSArray *propertyKeys = @[CNContactBirthdayKey,  CNContactGivenNameKey, CNContactFamilyNameKey];
            NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"birthday == nil && nonGregorianBirthday == nil && dates.@count == 0"];
            
            picker.displayedPropertyKeys = propertyKeys;
            picker.predicateForEnablingContact = enablePredicate;
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:nil];
            

        }
            break;
    }

}
#pragma mark
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    //for event
    if (item.tag == 3) {
        self.navigationItem.title = @"";
        [self.navigationController.navigationBar addSubview:self.segmentedControl];
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSegmentIndex"];
        [self.segmentedControl setSelectedSegmentIndex:index];
        [self controlEventValueChanged:nil];
    }
    else{
        self.navigationItem.title = item.title;
        if (self.segmentedControl.superview) {
            [self.segmentedControl removeFromSuperview];
        }
        
    }
//    [[UITabBarItem appearance] setSelectedImage:[item selectedImage]];
}
//- (void)tabBar:(UITabBar *)tabBar willEndCustomizingItems:(NSArray<UITabBarItem *> *)items changed:(BOOL)changed
//{
//    NSLog(@"willEndCustomizingItems");
//}
//- (void)tabBar:(UITabBar *)tabBar didEndCustomizingItems:(NSArray<UITabBarItem *> *)items changed:(BOOL)changed
//{
//    NSLog(@"didEndCustomizingItems");
//}

#pragma mark
/*!
 * @abstract Called when the user selects a single property.
 * @discussion Return NO if you do not want anything to be done or if you are handling the actions yourself.
 * Return YES if you want the default action performed for the property otherwise return NO.
 */
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property

{
    NSLog(@"property:%@",property);
    return YES;
}

/*!
 * @abstract Called when the view has completed.
 * @discussion If creating a new contact, the new contact added to the contacts list will be passed.
 * If adding to an existing contact, the existing contact will be passed.
 * @note It is up to the delegate to dismiss the view controller.
 */
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    if (!contact) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
         [[ReminderData defaultData] updateItemsWithContact:contact];
//        if (contact.birthday) {
//            NSLog(@"Birthday:%@",contact.birthday);
//            SWBirthCellItem* item = [SWBirthCellItem itemWithContact:contact];
//            [[ReminderData defaultData] addItem:item];
//        }
//        else if (contact.nonGregorianBirthday)
//        {
//            NSLog(@"nonGregorianBirthday:%@(%@)",contact.nonGregorianBirthday,[contact.nonGregorianBirthday.date descriptionWithLocale:[NSLocale currentLocale]]);
//            SWBirthCellItem* item = [SWBirthCellItem itemWithLunarContact:contact];
//            [[ReminderData defaultData] addItem:item];
//        }
//        else if ([contact.dates count] > 0)
//        {
//            for (CNLabeledValue* value in contact.dates) {
//                SWAnniversaryCellItem* item = [SWAnniversaryCellItem itemWithContact:contact label:value];
//                [[ReminderData defaultData] addItem:item];
//                
//            }
//            NSLog(@"Anniversary:%@",contact.dates);
//        }
    }
    
    NSLog(@"didCompleteWithContact %@",contact);
}
#pragma mark
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    CNContactViewController* viewController = [CNContactViewController viewControllerForContact:contact];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
