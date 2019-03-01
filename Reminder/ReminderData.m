//
//  ReminderData.m
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "ReminderData.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "SWBirthCellItem.h"
#import "SWAnniversaryCellItem.h"
#import "SWEventCellItem.h"
#import "NSDate+Function.h"
#import <CloudKit/CloudKit.h>

typedef enum
{
    NF_Current_DAY,
    NF_ONE_DAY_BEFORE,
    NF_THREE_DAYS_BEFORE,
    NF_ONE_WEEK_BEFORE
} NotifyDateType;

#define MAX_LOCAL_NOTIFICATION_COUNT 64

static ReminderData* g_dataModule = nil;
@implementation ReminderData

+(void)load
{
//    [[ReminderData defaultData] loadAddressBook];
}
+(instancetype)defaultData
{
    if (!g_dataModule) {
        g_dataModule = [[ReminderData alloc] init];
        [g_dataModule loadAddressBook];
    }
    return g_dataModule;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.allItems = [NSMutableArray array];
        self.birthdayArray = [NSMutableArray array];
        self.anniversaryArray = [NSMutableArray array];
        self.eventArray = [NSMutableArray array];
        self.pastEventArray = [NSMutableArray array];
         self.comingEventArray = [NSMutableArray array];
        
    }
    return self;
}
+(NSArray*)keytoFetch
{
    return [NSArray arrayWithObjects:CNContactIdentifierKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactDatesKey,CNContactImageDataKey,CNContactThumbnailImageDataKey, nil];
}
-(NSArray*)itemsWithIdentifer:(NSString*)identifer
{
    NSIndexSet* indexSet = [self.allItems indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SWCellItem* item = obj;
        return [item.identifier isEqualToString:identifer];
    }];
    
    return [self.allItems objectsAtIndexes:indexSet];
}

-(void)deleteItemsWithIdentifer:(NSString*)identifer
{
    NSArray* items = [self itemsWithIdentifer:identifer];
    for (SWCellItem * item in items) {
        [self removeItemAtIndex:[self.allItems indexOfObject:item] fromArray:self.allItems];
    }
}

-(void)updateItemsWithContact:(CNContact*)contact
{
    [self deleteItemsWithIdentifer:contact.identifier];
    
    if (contact.birthday) {
        [self addItem:[SWBirthCellItem itemWithContact:contact]];
    }
    if (contact.nonGregorianBirthday)
    {
        [self addItem:[SWBirthCellItem itemWithLunarContact:contact]];
    }
    if ([contact.dates count] > 0) {
        for (CNLabeledValue* value in contact.dates) {
            [self addItem:[SWAnniversaryCellItem itemWithContact:contact label:value]];
        }
        
    }
}
#pragma mark
-(void)loadAddressBook
{
    @synchronized (self) {

        @autoreleasepool {
            
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if (status == CNAuthorizationStatusAuthorized) {
                CNContactFetchRequest* request = [[CNContactFetchRequest alloc] initWithKeysToFetch:[[self class] keytoFetch]];
                request.predicate = nil;
                
                CNContactStore* store = [[CNContactStore alloc] init];
                [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                    if (contact.birthday) {
                        [self.birthdayArray addObject:[SWBirthCellItem itemWithContact:contact]];
                    }
                    if (contact.nonGregorianBirthday)
                    {
                         [self.birthdayArray addObject:[SWBirthCellItem itemWithLunarContact:contact]];
                    }
                    if ([contact.dates count] > 0) {
                        for (CNLabeledValue* value in contact.dates) {
                            [self.anniversaryArray addObject:[SWAnniversaryCellItem itemWithContact:contact label:value]];
                        }
                        
                    }
                    
                }];
                
                
                
                
                [self.allItems addObjectsFromArray:self.birthdayArray];
                [self.allItems addObjectsFromArray:self.anniversaryArray];
                [self sortArray:self.birthdayArray];
                [self sortArray:self.anniversaryArray];
                [self sortArray:self.allItems];
                
                [self loadEventData];

                
            }
            else{
                CNContactStore* store = [[CNContactStore alloc] init];
                [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    [self loadAddressBook];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewData" object:self];
                }];

            }

        }
        
        
    }
    
    
}
-(void)sortArray:(NSMutableArray*)array
{
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SWCellItem* item1 = obj1;
        SWCellItem* item2 = obj2;
        
        if (![item1 dateExpired]&&![item2 dateExpired]) {
            return [[item1 nextEventDate] compare:[item2 nextEventDate]];
        }
        else{
            return [[item2 nextEventDate] compare:[item1 nextEventDate]];
        }

        
        
    }];
}

-(void)addItem:(SWCellItem*)item
{
    switch (item.cellType) {
        case TABLE_CELL_EVENT:
            //[self.eventArray addObject:item];
        {
            if ([(SWEventCellItem*)item dateExpired]) {
                [self.pastEventArray addObject:item];
                [self sortArray:self.pastEventArray];
            }
            else{
                [self.comingEventArray addObject:item];
                [self sortArray:self.comingEventArray];
                
                
                
            }
            [self insertObject:item inEventArrayAtIndex:0];
            [self sortArray:_eventArray];
            
            [self iCloudAddEventItem:(SWEventCellItem*)item];
        }
            break;
        case TABLE_CELL_BIRTHDAY:
        case TABLE_CELL_BIRTHDAY_LUNAR:
            [self insertObject:item inBirthdayArrayAtIndex:0];
            [self sortArray:_birthdayArray];
            break;
        case TABLE_CELL_ANNIVERSARY:
            [self insertObject:item inAnniversaryArrayAtIndex:0];
            [self sortArray:_anniversaryArray];
            break;
        default:
            break;
    }
    
    [self insertObject:item inAllItemsAtIndex:0];
    [self sortArray:_allItems];
}
-(void)updateItem:(SWCellItem*)item
{
    switch (item.cellType) {
        case TABLE_CELL_EVENT:
        {
            if ([(SWEventCellItem*)item dateExpired]) {
                NSUInteger index = [self.comingEventArray indexOfObject:item];
                if (index !=NSNotFound) {
                    [self.comingEventArray removeObject:item];
                    [self.pastEventArray addObject:item];
                }
                [self sortArray:self.pastEventArray];
            }
            else{
                NSUInteger index = [self.pastEventArray indexOfObject:item];
                if (index !=NSNotFound) {
                    [self.pastEventArray removeObject:item];
                    [self.comingEventArray addObject:item];
                }
                [self sortArray:self.comingEventArray];
            }
            [self replaceObjectInEventArrayAtIndex:[self.eventArray indexOfObject:item] withObject:item];
            [self sortArray:_eventArray];
            
            [self iCloudModifyEventItem:(SWEventCellItem*)item];
        }
            break;
        case TABLE_CELL_BIRTHDAY:
        case TABLE_CELL_BIRTHDAY_LUNAR:
            [self insertObject:item inBirthdayArrayAtIndex:0];
            [self sortArray:_birthdayArray];
            break;
        case TABLE_CELL_ANNIVERSARY:
            [self insertObject:item inAnniversaryArrayAtIndex:0];
            [self sortArray:_anniversaryArray];
            break;
        default:
            break;
    }
    [self replaceObjectInAllItemsAtIndex:[self.allItems indexOfObject:item] withObject:item];
    [self sortArray:_allItems];
}
-(void)removeItemAtIndex:(NSUInteger)index fromArray:(NSMutableArray*)array
{
    SWCellItem* obj = [array objectAtIndex:index];
    [self removeObjectFromAllItemsAtIndex:[self.allItems indexOfObject:obj]];
    
    if (![array isEqual:self.allItems]) {
        if ([array isEqual:self.pastEventArray] || [array isEqual:self.comingEventArray]) {
            
            [self iCloudDeleteEventItem:(SWEventCellItem*)obj];
            [array removeObjectAtIndex:index];
            [self removeObjectFromEventArrayAtIndex:[self.eventArray indexOfObject:obj]];
            
        }
        else{
            if (obj.cellType==TABLE_CELL_BIRTHDAY||obj.cellType==TABLE_CELL_BIRTHDAY_LUNAR) {
                [self removeObjectFromBirthdayArrayAtIndex:index];
            }
            else{
                [self removeObjectFromAnniversaryArrayAtIndex:index];
            }
        }
    }
    else
    {
        if (obj.cellType == TABLE_CELL_EVENT) {
            [self iCloudDeleteEventItem:(SWEventCellItem*)obj];
            NSUInteger index = [self.pastEventArray indexOfObject:obj];
            if (index!=NSNotFound) {
                [self.pastEventArray removeObject:obj];
            }
            else{
                index = [self.comingEventArray indexOfObject:obj];
                if (index!=NSNotFound) {
                    [self.comingEventArray removeObject:obj];
                }
            }
            [self removeObjectFromEventArrayAtIndex:[self.eventArray indexOfObject:obj]];
        }
        else if (obj.cellType==TABLE_CELL_BIRTHDAY || obj.cellType==TABLE_CELL_BIRTHDAY_LUNAR) {
            [self removeObjectFromBirthdayArrayAtIndex:[self.birthdayArray indexOfObject:obj]];
        }
        else{
            [self removeObjectFromAnniversaryArrayAtIndex:[self.anniversaryArray indexOfObject:obj]];
        }
    }


}

- (CKDatabase*)cloudDatabase
{
    CKContainer *myContainer = [CKContainer defaultContainer];
    //CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.com.example.ajohnson.GalleryShared"];
    return [myContainer privateCloudDatabase];
}
-(void)iCloudAddEventItem:(SWEventCellItem*)item
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus != CKAccountStatusNoAccount) {
            if (!item.identifier) {
                item.identifier = [NSUUID UUID].UUIDString;
            }
            CKRecordID *eventRecordID = [[CKRecordID alloc] initWithRecordName:item.identifier];
            CKRecord *artworkRecord = [[CKRecord alloc] initWithRecordType:@"Event" recordID:eventRecordID];
            artworkRecord[@"eventDate" ] = item.eventDate;
            artworkRecord[@"eventDescription"] = item.eventDescription;
            artworkRecord[@"identifier"] = item.identifier;
            artworkRecord[@"repeatType"] = [NSNumber numberWithInteger:item.repeatType] ;
            artworkRecord[@"alreadyFinished"] = [NSNumber numberWithBool:item.alreadyFinished] ;
            artworkRecord[@"finishedDate" ] = item.finishedDate;
            

            CKDatabase *privateDatabase = [self cloudDatabase];
            [privateDatabase saveRecord:artworkRecord completionHandler:^(CKRecord *artworkRecord, NSError *error){
                if (error) {
                    [self displayError:error];
                }
                else {
                    NSLog(@"Add icloud event:%@",item.eventDescription);
                }
            }];
        }
    }];

}

-(void)iCloudModifyEventItem:(SWEventCellItem*)item
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus != CKAccountStatusNoAccount) {
            if (item.identifier) {
                CKRecordID *eventRecordID = [[CKRecordID alloc] initWithRecordName:item.identifier];
                CKDatabase *privateDatabase = [self cloudDatabase];
                [privateDatabase fetchRecordWithID:eventRecordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    if (error) {
                        [self displayError:error];
                    }
                    else{
                        record[@"eventDate" ] = item.eventDate;
                        record[@"eventDescription"] = item.eventDescription;
                        record[@"identifier"] = item.identifier;
                        record[@"repeatType"] = [NSNumber numberWithInteger:item.repeatType] ;
                        record[@"alreadyFinished"] = [NSNumber numberWithBool:item.alreadyFinished] ;
                        record[@"finishedDate" ] = item.finishedDate;
                        
                        [privateDatabase saveRecord:record completionHandler:^(CKRecord *artworkRecord, NSError *error){
                            if (error) {
                                [self displayError:error];
                            }
                            else {
                                NSLog(@"Modify icloud event:%@",item.eventDescription);
                            }
                        }];
                    }

                }];
            }
        }
    }];
    

}
-(void)iCloudDeleteEventItem:(SWEventCellItem*)item
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus != CKAccountStatusNoAccount) {
            if (item.identifier) {
                CKRecordID *eventRecordID = [[CKRecordID alloc] initWithRecordName:item.identifier];
                CKDatabase *privateDatabase = [self cloudDatabase];
                [privateDatabase deleteRecordWithID:eventRecordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                    if (error) {
                        [self displayError:error];
                    }
                    else{
                        NSLog(@"Delete icloud event:%@",item.eventDescription);
                    }
                }];
            }
        }
    }];


}
-(void)saveEventData
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus != CKAccountStatusNoAccount) {
//            for (SWEventCellItem* item in self.eventArray) {
//                [self iCloudModifyEventItem:item];
//            }
        }
        else{
            NSString* path =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"reminder_eventArray.data"];
            if (![NSKeyedArchiver archiveRootObject:self.eventArray toFile:path]) {
                NSLog(@"Failed to save event data at path: %@.",path);
            }

        }
        
    }];
    
}
-(void)dispatchEventData
{
    for (SWEventCellItem* item in self.eventArray) {
        
        if (item.repeatType != rtNever) {
            
            if ([item autoFixAlreadyFinishedVariant]) {
                [self iCloudModifyEventItem:item];
            }
            [self.comingEventArray addObject:item];
            
        }
        else{
            if ([(SWEventCellItem*)item dateExpired]) {
                [self.pastEventArray addObject:item];
            }
            else{
                [self.comingEventArray addObject:item];
            }
        }
        
    }
    [self sortArray:self.pastEventArray];
    [self sortArray:self.comingEventArray];
    
    [self.allItems addObjectsFromArray:self.eventArray];
    [self sortArray:self.allItems];
}
-(void)loadEventData
{
    
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if(accountStatus != CKAccountStatusNoAccount)
        //if(0)
        {
            CKDatabase *privateDatabase = [self cloudDatabase];
            CKQuery* eventQuery = [[CKQuery alloc] initWithRecordType:@"Event" predicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
            [privateDatabase performQuery:eventQuery inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
                
                [self.allItems removeObjectsInArray:self.eventArray];
                [self.eventArray removeAllObjects];
                [self.pastEventArray removeAllObjects];
                [self.comingEventArray removeAllObjects];
                
                for (CKRecord* record in results) {
                    SWEventCellItem* item = [[SWEventCellItem alloc] initWithRecord:record];
                    [self.eventArray addObject:item];
                }
                
                [self dispatchEventData];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewData" object:self];
            }];
        }
        else{
            
            [self.allItems removeObjectsInArray:self.eventArray];
            [self.eventArray removeAllObjects];
            [self.pastEventArray removeAllObjects];
            [self.comingEventArray removeAllObjects];
            
            NSString* path =  [NSTemporaryDirectory() stringByAppendingPathComponent:@"reminder_eventArray.data"];
            [self.eventArray addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];

            [self dispatchEventData];
            
            [self saveEventData];
        }
        
        
        
    }];
    
    

}
#pragma mark Notification
-(void)schelduleLocalNotification
{
    @synchronized(self)
    {
        NSLog(@"Start scheduling local notifications...");
        //删除原来的
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        

//        //取子数组，减少运算量
        NSArray* tmpList = [self.allItems subarrayWithRange:NSMakeRange(0, MIN([self.allItems count],MAX_LOCAL_NOTIFICATION_COUNT))];

//        //计算提前通知事件
//        NSArray* preEventList = [self advanceEventListFrom:sortEventList];
//        //        DailyLog(@"iOS v%f",atof([[UIDevice currentDevice].systemVersion UTF8String]));
//        
        NSMutableArray* notifications = [[NSMutableArray alloc] init];
        NSInteger scheduleCount = 0;
//        
//        NSArray* prevNotificatons = [self scheduleLocalNotification:preEventList schedureCount:&scheduleCount notifyDateType:[LYSettingProperties shareSettingProp].notifyDateType];
//        if (prevNotificatons) {
//            [notifications addObjectsFromArray:prevNotificatons];
//        }
//        
        NSArray* curNotificatons = [self scheduleLocalNotification:tmpList schedureCount:&scheduleCount notifyDateType:NF_Current_DAY];
        if (curNotificatons) {
            [notifications addObjectsFromArray:curNotificatons];
        }
        if ([notifications count] > 0) {
            [UIApplication sharedApplication].scheduledLocalNotifications = notifications;
            NSLog(@"Patch schedule local notifications!");
        }

    }
}

-(NSArray*)scheduleLocalNotification:(NSArray*)eventList schedureCount:(NSInteger*)schelduleCount notifyDateType:(NotifyDateType)notifyType
{
    NSDate* previousDate = nil;
    NSDate* fireDate = nil;
    TABLE_CELL_TYPE previousEventCategory = 0;
    SWCellItem* previousDetail = nil;
    
    UILocalNotification* notification = nil;
    
//    float version = atof([[UIDevice currentDevice].systemVersion UTF8String]);
    BOOL patchSchedule = YES;
    NSMutableArray* notifications =nil;
    if (patchSchedule) {
        notifications = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray* birthNames = [[NSMutableArray alloc] init];
    NSMutableArray* annivNames = [[NSMutableArray alloc] init];
    NSMutableArray* eventDescriptions = [[NSMutableArray alloc] init];
    
    NSInteger  eventNum = 0;
    for (int i = 0; i < [eventList count]; i++)
    {
        
        if (*schelduleCount == MAX_LOCAL_NOTIFICATION_COUNT-1) {
            break;
        }
        SWCellItem* detail = [eventList objectAtIndex:i];
        if ([detail dateExpired]) {
            continue;
        }
        fireDate = [detail nextFireDate];
        
        if (!previousDate || [fireDate compare:previousDate]== NSOrderedSame) {
            //修改alertBody
            switch (detail.cellType) {
                case TABLE_CELL_BIRTHDAY:
                case TABLE_CELL_BIRTHDAY_LUNAR:
                    if ([self isInChinese]) {
                        [birthNames addObject:[NSString stringWithFormat:@"%@ %@",detail.familyName,detail.givenName]];
                    }
                    else{
                        [birthNames addObject:[NSString stringWithFormat:@"%@ %@",detail.givenName,detail.familyName]];
                    }
                    
                    break;
                case TABLE_CELL_ANNIVERSARY:
                    if ([self isInChinese]) {
                        [annivNames addObject:[NSString stringWithFormat:@"%@ %@",detail.familyName,detail.givenName]];
                    }
                    else{
                        [annivNames addObject:[NSString stringWithFormat:@"%@ %@",detail.givenName,detail.familyName]];
                    }
                    break;
                default:
                    eventNum++;
                    [eventDescriptions addObject:detail.eventDescription];
                    break;
            }
            
            if (!previousDate) {
                notification = [self localNotification];
                notification.fireDate = fireDate;
                notification.repeatInterval = [self repeatIntervalFromItem:detail];
                notification.applicationIconBadgeNumber = 1;
            } else {
                notification.applicationIconBadgeNumber++;
            }
        }
        else if (previousDate!=nil && [fireDate compare:previousDate]!= NSOrderedSame )
        {
            
            if (notification) {
                notification.alertBody = [self alertBodyFromBirth:birthNames anniv:annivNames eventDesc:eventDescriptions notifyDateType:notifyType];
                
//                LYSettingProperties *setting = [LYSettingProperties shareSettingProp];
//                
//                if (!setting.useIconBadge) {
//                    notification.applicationIconBadgeNumber = 0;
//                }
                if (patchSchedule) {
                    [notifications addObject:notification];
                }
                else
                {
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
                
                NSLog(@"Schedule %@ msg:%@",[notification.fireDate descriptionWithLocale:[NSLocale currentLocale]],notification.alertBody);
                (*schelduleCount)++;
            }
            
            [birthNames removeAllObjects];
            [annivNames removeAllObjects];
            [eventDescriptions removeAllObjects];
            eventNum = 0;
            
            switch (detail.cellType) {
                case TABLE_CELL_BIRTHDAY:
                case TABLE_CELL_BIRTHDAY_LUNAR:
                    if ([self isInChinese]) {
                        [birthNames addObject:[NSString stringWithFormat:@"%@%@",detail.familyName,detail.givenName]];
                    }
                    else{
                        [birthNames addObject:[NSString stringWithFormat:@"%@ %@",detail.givenName,detail.familyName]];
                    }
                    break;
                case TABLE_CELL_ANNIVERSARY:
                    if ([self isInChinese]) {
                        [annivNames addObject:[NSString stringWithFormat:@"%@%@",detail.familyName,detail.givenName]];
                    }
                    else{
                        [annivNames addObject:[NSString stringWithFormat:@"%@ %@",detail.givenName,detail.familyName]];
                    }
                    break;
                default:
                {
                    eventNum = 1;
                    [eventDescriptions addObject:detail.eventDescription];
                }
                    break;
                    
                    
            }
            notification = [self localNotification];
            notification.fireDate = fireDate;
            notification.repeatInterval = [self repeatIntervalFromItem:detail];
            notification.applicationIconBadgeNumber = 1;
            
        }

        previousDate = fireDate;
        previousEventCategory = detail.cellType;
        previousDetail = detail;
    }
    
    if ([birthNames count]!=0 || [annivNames count] != 0 || [eventDescriptions count] != 0)
    {
        //注册最后一个
        notification.alertBody = [self alertBodyFromBirth:birthNames anniv:annivNames eventDesc:eventDescriptions notifyDateType:notifyType];
        if (patchSchedule) {
            [notifications addObject:notification];
        }
        else
        {
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        NSLog(@"schedule %@ msg:%@",[notification.fireDate descriptionWithLocale:[NSLocale currentLocale]],notification.alertBody);
        (*schelduleCount)++;
    }
    
    return notifications;
}
-(BOOL)isInChinese
{
    NSString* languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    return [languageCode isEqualToString:@"zh"];
}
-(NSString*) alertBodyFromBirth:(NSArray*)birthNames anniv:(NSArray*)annivNames eventDesc:(NSArray*)eventDesc notifyDateType:(NotifyDateType)notifyType
{
    if ([birthNames count]==0&&[annivNames count]==0&&[eventDesc count]==0) {
        return nil;
    }
    

    NSInteger eventNum = [eventDesc count];

    NSString*dayString = nil;
    switch (notifyType) {
        case NF_ONE_WEEK_BEFORE:
            dayString = NSLocalizedString(@"Oneweeklater",nil);
            break;
        case NF_THREE_DAYS_BEFORE:
            dayString = NSLocalizedString(@"Threedayslater",nil);
            break;
        case NF_ONE_DAY_BEFORE:
            dayString = NSLocalizedString(@"Tomorrow",nil);
            break;
        case NF_Current_DAY:
        default:
            dayString = NSLocalizedString(@"Today",nil);
            break;
    }
    
    NSString* alertBoady;
    if ([birthNames count]!=0 && [annivNames count]==0&& eventNum==0) {
        if (notifyType!=NF_Current_DAY) {
            if (![self isInChinese]) {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirth", nil),[self namesFromArray:birthNames],dayString];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirth", nil),dayString,[self namesFromArray:birthNames]];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todaybirth", nil),[self namesFromArray:birthNames]];
        }
        
    }
    else if([birthNames count]==0 && [annivNames count]!=0&& eventNum==0)
    {
        if (notifyType!=NF_Current_DAY) {
            
            if (![self isInChinese]) {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willanniver", nil),[self namesFromArray:annivNames],dayString];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willanniver", nil),dayString,[self namesFromArray:annivNames]];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todayanniver", nil),[self namesFromArray:annivNames]];
        }
    }
    else if([birthNames count]==0 && [annivNames count]==0&& eventNum!=0)
    {
        if (notifyType!=NF_Current_DAY) {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willtodo", nil),eventNum,dayString];
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todaytodo", nil),[self descriptionMergeFromArray:eventDesc]];
        }
    }
    else if([birthNames count]!=0 && [annivNames count]!=0&& eventNum==0)
    {
        if (notifyType!=NF_Current_DAY) {
            if(![self isInChinese])
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirthanniv", nil),[self namesFromArray:birthNames],[self namesFromArray:annivNames],dayString];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirthanniv", nil),dayString,[self namesFromArray:birthNames],[self namesFromArray:annivNames]];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todaybirthanniv", nil),[self namesFromArray:birthNames],[self namesFromArray:annivNames]];
        }
        
    }
    else if([birthNames count]!=0 && [annivNames count]==0&& eventNum!=0)
    {
        if (notifyType!=NF_Current_DAY) {
            if(![self isInChinese])
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirthtodo", nil),[self namesFromArray:birthNames],dayString,eventNum];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willbirthtodo", nil),dayString,[self namesFromArray:birthNames],eventNum];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todaybirthtodo", nil),[self namesFromArray:birthNames],[self descriptionMergeFromArray:eventDesc]];
        }
    }
    else if([birthNames count]==0 && [annivNames count]!=0&& eventNum!=0)
    {
        if (notifyType!=NF_Current_DAY) {
            if(![self isInChinese])
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willannivtodo", nil),[self namesFromArray:annivNames],dayString,eventNum];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willannivtodo", nil),dayString,[self namesFromArray:annivNames],eventNum];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todayannivtodo", nil),[self namesFromArray:annivNames],[self descriptionMergeFromArray:eventDesc]];
        }
    }
    else
    {
        if (notifyType!=NF_Current_DAY) {
            if(![self isInChinese])
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willall", nil),[self namesFromArray:birthNames],[self namesFromArray:annivNames],dayString,eventNum];
            }
            else
            {
                alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Willall", nil),dayString,[self namesFromArray:birthNames],[self namesFromArray:annivNames],eventNum];
            }
            
        }
        else
        {
            alertBoady = [NSString stringWithFormat:NSLocalizedString(@"Todayall", nil),[self namesFromArray:birthNames],[self namesFromArray:annivNames],[self descriptionMergeFromArray:eventDesc]];
        }
    }

    NSString *tempResult = [alertBoady stringByAppendingString:NSLocalizedString(@"Timefordetails",nil)];
    return tempResult;
}

-(NSString*)namesFromArray:(NSArray*)names
{
    assert([names count]!=0);
    NSString* nameString = [names objectAtIndex:0];
    for (int i = 1; i < [names count]; i++) {
        nameString = [nameString stringByAppendingString: NSLocalizedString(@"Comma",nil)];
        nameString = [nameString stringByAppendingString:[names objectAtIndex:i]];
    }
    return nameString;
}

-(NSString*)descriptionMergeFromArray:(NSArray*)descs
{
    assert([descs count]!=0);
    NSString* descString = [descs objectAtIndex:0];
    for (int i = 1; i < [descs count]; i++) {
        descString = [descString stringByAppendingString: NSLocalizedString(@"Comma",nil)];
        descString = [descString stringByAppendingString:[descs objectAtIndex:i]];
    }
    return descString;
}
-(UILocalNotification*)localNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone= [NSTimeZone defaultTimeZone];
    notification.soundName = [self systemAudioFile];
    notification.hasAction = TRUE;
    return notification;
}

-(NSString*)systemAudioFile
{
#if TARGET_IPHONE_SIMULATOR
    return @"ping.caf";
#elif TARGET_OS_IPHONE
    NSString *path = @"/System/Library/Audio/UISounds";
    path = [path stringByAppendingPathComponent: @"new-mail.caf"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
        path = @"ping.caf";
    }
    return path;
#endif
}


-(NSCalendarUnit)repeatIntervalFromItem:(SWCellItem*) item
{
    switch (item.cellType) {
        case TABLE_CELL_BIRTHDAY:
        case TABLE_CELL_BIRTHDAY_LUNAR:
        case TABLE_CELL_ANNIVERSARY:
            return NSCalendarUnitYear;
            
        default:
            switch (((SWEventCellItem*)item).repeatType) {
                case rtWeek:
                    return NSCalendarUnitWeekday;
                case rtMonth:
                    return NSCalendarUnitMonth;
                case rtYear:
                    return NSCalendarUnitYear;
                default:
                    return NSCalendarUnitYear;
            }
    }
}
#pragma mark
-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [self removeObserver:observer forKeyPath:keyPath];
}

#pragma mark _eventArray KVC
/*KVC 兼容必须实现函数*/
- (NSUInteger)countOfEventArray
{
    return [_eventArray count];
}

- (id)objectInEventArrayAtIndex:(NSUInteger)index
{
    return [_eventArray objectAtIndex:index];
}
- (NSArray *)eventArrayAtIndexes:(NSIndexSet *)indexes
{
    return [_eventArray objectsAtIndexes:indexes];
}

- (void)getEventArray:(SWCellItem __unsafe_unretained **)buffer range:(NSRange)inRange
{
    // Return the objects in the specified range in the provided
    // buffer. For example, if the _eventArray were stored in an
    // underlying NSArray
    [_eventArray getObjects:buffer range:inRange];
}

- (void)insertObject:(SWCellItem *)image inEventArrayAtIndex:(NSUInteger)index
{
    [_eventArray insertObject:image atIndex:index];
    //resetPosition放到外部调用
}
- (void)insertEventArray:(NSArray *)eventArray atIndexes:(NSIndexSet *)indexes
{
    
    [_eventArray insertObjects:eventArray atIndexes:indexes];
    //resetPosition放到外部调用
}

- (void)removeObjectFromEventArrayAtIndex:(NSUInteger)index
{
    [_eventArray removeObjectAtIndex:index];
}

- (void)removeEventArrayAtIndexes:(NSIndexSet *)indexes
{
    [_eventArray removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInEventArrayAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_eventArray replaceObjectAtIndex:index withObject:anObject];
    //resetPosition放到外部调用
}
- (void)replaceEventArrayAtIndexes:(NSIndexSet *)indexes withEventArray:(NSArray *)items
{
    [_eventArray replaceObjectsAtIndexes:indexes withObjects:items];
    //resetPosition放到外部调用
}
#pragma mark
- (NSUInteger)countOfAllItems
{
    return [_allItems count];
}

- (id)objectInAllItemsAtIndex:(NSUInteger)index
{
    return [_allItems objectAtIndex:index];
}
- (NSArray *)allItemsAtIndexes:(NSIndexSet *)indexes
{
    return [_allItems objectsAtIndexes:indexes];
}

- (void)getAllItems:(SWCellItem __unsafe_unretained **)buffer range:(NSRange)inRange
{
    [_allItems getObjects:buffer range:inRange];
}

- (void)insertObject:(SWCellItem *)image inAllItemsAtIndex:(NSUInteger)index
{
    [_allItems insertObject:image atIndex:index];
}
- (void)insertAllItems:(NSArray *)eventArray atIndexes:(NSIndexSet *)indexes
{
    [_allItems insertObjects:eventArray atIndexes:indexes];
}

- (void)removeObjectFromAllItemsAtIndex:(NSUInteger)index
{
    [_allItems removeObjectAtIndex:index];
}

- (void)removeAllItemsAtIndexes:(NSIndexSet *)indexes
{
    [_allItems removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInAllItemsAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_allItems replaceObjectAtIndex:index withObject:anObject];
}
- (void)replaceAllItemsAtIndexes:(NSIndexSet *)indexes withAllItems:(NSArray *)items
{
    [_allItems replaceObjectsAtIndexes:indexes withObjects:items];
}
#pragma mark
- (NSUInteger)countOfBirthdayArray
{
    return [_birthdayArray count];
}

- (id)objectInBirthdayArrayAtIndex:(NSUInteger)index
{
    return [_birthdayArray objectAtIndex:index];
}
- (NSArray *)birthdayArrayAtIndexes:(NSIndexSet *)indexes
{
    return [_birthdayArray objectsAtIndexes:indexes];
}

- (void)getBirthdayArray:(SWCellItem __unsafe_unretained **)buffer range:(NSRange)inRange
{
    [_birthdayArray getObjects:buffer range:inRange];
}

- (void)insertObject:(SWCellItem *)image inBirthdayArrayAtIndex:(NSUInteger)index
{
    [_birthdayArray insertObject:image atIndex:index];
}
- (void)insertBirthdayArray:(NSArray *)eventArray atIndexes:(NSIndexSet *)indexes
{
    [_birthdayArray insertObjects:eventArray atIndexes:indexes];
}

- (void)removeObjectFromBirthdayArrayAtIndex:(NSUInteger)index
{
    [_birthdayArray removeObjectAtIndex:index];
}

- (void)removeBirthdayArrayAtIndexes:(NSIndexSet *)indexes
{
    [_birthdayArray removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInBirthdayArrayAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_birthdayArray replaceObjectAtIndex:index withObject:anObject];
}
- (void)replaceBirthdayArrayAtIndexes:(NSIndexSet *)indexes withBirthdayArray:(NSArray *)items
{
    [_birthdayArray replaceObjectsAtIndexes:indexes withObjects:items];
}

#pragma mark
- (NSUInteger)countOfAnniversaryArray
{
    return [_anniversaryArray count];
}

- (id)objectInAnniversaryArrayAtIndex:(NSUInteger)index
{
    return [_anniversaryArray objectAtIndex:index];
}
- (NSArray *)anniversaryArrayAtIndexes:(NSIndexSet *)indexes
{
    return [_anniversaryArray objectsAtIndexes:indexes];
}

- (void)getAnniversaryArray:(SWCellItem __unsafe_unretained **)buffer range:(NSRange)inRange
{
    [_anniversaryArray getObjects:buffer range:inRange];
}

- (void)insertObject:(SWCellItem *)image inAnniversaryArrayAtIndex:(NSUInteger)index
{
    [_anniversaryArray insertObject:image atIndex:index];
}
- (void)insertAnniversaryArray:(NSArray *)eventArray atIndexes:(NSIndexSet *)indexes
{
    [_anniversaryArray insertObjects:eventArray atIndexes:indexes];
}

- (void)removeObjectFromAnniversaryArrayAtIndex:(NSUInteger)index
{
    [_anniversaryArray removeObjectAtIndex:index];
}

- (void)removeAnniversaryArrayAtIndexes:(NSIndexSet *)indexes
{
    [_anniversaryArray removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInAnniversaryArrayAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_anniversaryArray replaceObjectAtIndex:index withObject:anObject];
}
- (void)replaceAnniversaryArrayAtIndexes:(NSIndexSet *)indexes withAnniversaryArray:(NSArray *)items
{
    [_anniversaryArray replaceObjectsAtIndexes:indexes withObjects:items];
}
#pragma mark
-(void)displayTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    assert([UIApplication sharedApplication].keyWindow !=nil);
    [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:alert animated:YES completion:nil];
}
-(void)displayError:(NSError*)error
{
    [self displayTitle:@"Error" message:[error localizedDescription]];
}

-(void)subscriptionEventNotification
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKSubscription *subscription = [[CKSubscription alloc]
                                    initWithRecordType:@"Event"
                                    predicate:predicate
                                    options:CKSubscriptionOptionsFiresOnRecordCreation|CKSubscriptionOptionsFiresOnRecordUpdate|CKSubscriptionOptionsFiresOnRecordDeletion];
    
    NSLog(@"subscriptionID: %@",subscription.subscriptionID);
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    notificationInfo.alertLocalizationKey = @"Event is updating in another device.";
    notificationInfo.shouldBadge = YES;
    
    subscription.notificationInfo = notificationInfo;
    
    CKDatabase *database = [self cloudDatabase];
    [database saveSubscription:subscription
             completionHandler:^(CKSubscription *sub, NSError *error) {
                 if (error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self displayError:error];
                     });
                 }
             }
     ];
}
-(void)test
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus == CKAccountStatusNoAccount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in to iCloud"
                                                                               message:@"Sign in to your iCloud account to synchronize event data. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];
                assert([UIApplication sharedApplication].keyWindow !=nil);
                [[UIApplication sharedApplication].keyWindow.rootViewController  presentViewController:alert animated:YES completion:nil];
            });

        }
        else {


            
            CKDatabase *database = [self cloudDatabase];
            [database fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
                if (error || [subscriptions count] ==0) {
                    
                    [self subscriptionEventNotification];
  
                }
                else{
                    for (CKSubscription* subscription in subscriptions) {
                        
                        [database saveSubscription:subscription
                                 completionHandler:^(CKSubscription *sub, NSError *error) {
                                     if (error)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self displayError:error];
                                         });
                                     }
                                 }
                         ];
                    }
                }
            }];
            
        }
    }];
   



}
@end
