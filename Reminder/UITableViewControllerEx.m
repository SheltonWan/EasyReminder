//
//  UITableViewControllerEx.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "UITableViewControllerEx.h"
#import "ReminderData.h"
#import "UITableCellView.h"

#import <ContactsUI/ContactsUI.h>
#import "EventDetailViewController.h"

@interface UITableViewControllerEx ()<CNContactViewControllerDelegate>
{
    UISegmentedControl* _segmentedControl;
}
@end

@implementation UITableViewControllerEx
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[ReminderData defaultData] addObserver:self forKeyPath:[self keyPathToObserver]];

    NSArray* subviews = [self.navigationBar subviews];
    for (id view in subviews) {
        if ([view isKindOfClass:[UISegmentedControl class]]) {
            _segmentedControl = view;
            break;
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData:) name:@"reloadTableViewData" object:nil];
}
-(void)reloadTableViewData:(id)sender
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addItem:(SWCellItem*)item
{

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
// #warning Incomplete implementation, return the number of sections
    
    return 1;
}
- (NSString*)keyPathToObserver
{
    NSString* keyPath = nil;
    switch (self.cellType) {
        case TABLE_CELL_ALL:
            keyPath = @"allItems";
            break;
        case TABLE_CELL_BIRTHDAY:
            keyPath = @"birthdayArray";
            break;
        case TABLE_CELL_ANNIVERSARY:
            keyPath = @"anniversaryArray";
            break;
        case TABLE_CELL_EVENT:
            keyPath = @"eventArray";
        default:
            break;
    }
    return keyPath;
}
- (NSMutableArray*)tableArray
{
    NSMutableArray* array = nil;
    switch (self.cellType) {
        case TABLE_CELL_ALL:
            array = [ReminderData defaultData].allItems;
            break;
        case TABLE_CELL_BIRTHDAY:
            array = [ReminderData defaultData].birthdayArray;
            break;
        case TABLE_CELL_ANNIVERSARY:
            array = [ReminderData defaultData].anniversaryArray;
            break;
        case TABLE_CELL_EVENT:
            if (_segmentedControl.selectedSegmentIndex == 0) {
                array = [ReminderData defaultData].comingEventArray;
            }
            else{
                array = [ReminderData defaultData].pastEventArray;
            }
            
        default:
            break;
    }
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ReminderData* data = [ReminderData defaultData];
    @synchronized (data) {
//        NSLog(@"data number: %ld",[[ReminderData defaultData].birthdayArray count]);
        return [[self tableArray] count];
    }
}



//cell循环再用，注意subview不断重叠添加
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    // Configure the cell...
    

    
    UITableCellView* view = [cell.contentView subviews].firstObject;
    if (!view)
    {
        view = [[UITableCellView alloc] initWithFrame:CGRectMake(4.5, 0, cell.contentView.bounds.size.width-9, cell.contentView.bounds.size.height)];
        view.opaque = NO;
        view.selected = cell.isSelected;
        [self updateCellViewContent:view atRowIndex:indexPath.row];
        [cell.contentView addSubview:view];
    }
    else{
        view.selected = cell.isSelected;
        [self updateCellViewContent:view atRowIndex:indexPath.row];
        [view setNeedsDisplay];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    //    [self updateButtonsToMatchTableState];

    SWCellItem* item = [[self tableArray] objectAtIndex:indexPath.row];
    
    //NSLog(@"Select cell at %@:%@[%@]",view.name,view.displayDate,item.identifier);
    if (item.cellType != TABLE_CELL_EVENT) {
        CNContactStore* store = [[CNContactStore alloc] init];
        
        NSMutableArray* keys = [NSMutableArray arrayWithObject:CNContactViewController.descriptorForRequiredKeys];
        [keys addObjectsFromArray:[ReminderData keytoFetch]];
        CNContact* contact = [store unifiedContactWithIdentifier:item.identifier keysToFetch:keys error:nil];
        
        ;
        if (contact) {
            CNContactViewController* viewController = [CNContactViewController viewControllerForContact:contact];
            viewController.delegate = self;
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
    }
    else{
        if (_segmentedControl.superview) {
            [_segmentedControl removeFromSuperview];
        }
        EventDetailViewController* viewController = [EventDetailViewController viewControllerWithItem:item];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//
        SWCellItem* item = [[self tableArray] objectAtIndex:indexPath.row];
        if (item.cellType != TABLE_CELL_EVENT) {
            
            [self deleteUpdateContactForItem:item];
            
        }
        [[ReminderData defaultData] removeItemAtIndex:indexPath.row fromArray:[self tableArray]];
        
//        [tableView endUpdates];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate && scrollView.contentOffset.y < 0 && (self.cellType==TABLE_CELL_EVENT || self.cellType == TABLE_CELL_ALL)) {
        NSLog(@"Update Event table view...");
        [[ReminderData defaultData] loadEventData];
    }
}
-(void)deleteUpdateContactForItem:(SWCellItem*)item
{
    CNContactStore* store = [[CNContactStore alloc] init];
    NSError* err = nil;
    
    NSMutableArray* keys = [NSMutableArray arrayWithObject:CNContactViewController.descriptorForRequiredKeys];
    [keys addObjectsFromArray:[ReminderData keytoFetch]];
    CNContact* oldContact = [store unifiedContactWithIdentifier:item.identifier keysToFetch:keys error:nil];
    if (oldContact) {
        CNMutableContact* newContact = [oldContact mutableCopy];
        
        if (item.cellType == TABLE_CELL_BIRTHDAY) {
            newContact.birthday = nil;
        }
        else if (item.cellType == TABLE_CELL_BIRTHDAY_LUNAR) {
            newContact.nonGregorianBirthday = nil;
        }
        else{
            
            NSMutableArray* newDates = [NSMutableArray arrayWithArray: newContact.dates];
            for (CNLabeledValue* obj in newDates) {
                NSDateComponents* cp = obj.value;
                if ([cp.date compare:item.dateComponents.date] == NSOrderedSame) {
                    [newDates removeObject:obj];
                    break;
                }
            }
            newContact.dates = newDates;
            
        }
        
        
        CNSaveRequest* req = [[CNSaveRequest alloc] init];
        [req updateContact:newContact];
        BOOL result = [store executeSaveRequest:req error:&err];
        if (!result) {
            NSLog(@"%@",[err localizedDescription]);
        }
    }
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark
- (void)updateCellViewContent:(UITableCellView *)view atRowIndex:(NSInteger)index {
    SWCellItem* item = [[self tableArray] objectAtIndex:index];
    view.cellType = item.cellType;
    
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSString* languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    if (view.cellType==TABLE_CELL_EVENT) {
        view.eventTitle = item.eventDescription;
        view.name = nil;
    }
    else{
        if ([languageCode isEqualToString:@"zh" ]||[languageCode isEqualToString:@"ko" ]||[languageCode isEqualToString:@"ja" ]) {
            view.name = [NSString stringWithFormat:@"%@%@",item.familyName,item.givenName];//根据区域
        }
        else{
            view.name = [NSString stringWithFormat:@"%@ %@",item.givenName,item.familyName];//根据区域
        }
        view.eventTitle = nil;
    }
    
    
    view.displayDate = [item nextEventDate];
    view.isToday = [item isToday:view.displayDate];
    view.ages = [item ages];
    view.leftDays = [NSDate leftDaysToDate:view.displayDate];
    view.face = [UIImage imageWithData:item.thumbnailImageData];
    
    if ([item isKindOfClass:[SWAnniversaryCellItem class]]) {
        view.dateLabel = ((SWAnniversaryCellItem*)item).label;
    }
    else
    {
        view.dateLabel = nil;
    }
}
//这里代码有跟UITabBarControllerEx部分代码相似
#pragma mark
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"eventArray"]) {
        NSUInteger kind = [[change objectForKey:@"kind"] intValue];
        
        switch (kind) {
            case NSKeyValueChangeRemoval:
                break;
            case NSKeyValueChangeReplacement:
            case NSKeyValueChangeInsertion:
            {
                SWCellItem* item = ((NSArray*)[change objectForKey:@"new"]).firstObject;
                if ([(SWEventCellItem*)item dateExpired]) {
                    [_segmentedControl setSelectedSegmentIndex:1];
                }
                else{
                    [_segmentedControl setSelectedSegmentIndex:0];
                }
                
                if (_segmentedControl.selectedSegmentIndex==1) {
                    UIImage* image1 = [[UIImage imageNamed:@"segmentBackground"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    
                    [_segmentedControl setBackgroundImage:image1 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                    [_segmentedControl setBackgroundImage:image1 forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
                }
                else{
                    UIImage* image1 = [[UIImage imageNamed:@"segmentBackground_Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    
                    [_segmentedControl setBackgroundImage:image1 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                    [_segmentedControl setBackgroundImage:image1 forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
                }
                [[NSUserDefaults standardUserDefaults] setInteger:_segmentedControl.selectedSegmentIndex forKey:@"selectedSegmentIndex"];
            }
                break;
                
            default:
                break;
        }
        
    }

    
    [self.tableView reloadData];
    
    NSLog(@"Update %@...",keyPath);
    
}
#pragma mark update contact
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    [[ReminderData defaultData] updateItemsWithContact:contact];
}
@end
