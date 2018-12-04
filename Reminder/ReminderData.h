//
//  ReminderData.h
//  Reminder
//
//  Created by Shelton on 8/9/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWBirthCellItem.h"
#import "SWAnniversaryCellItem.h"

@interface ReminderData : NSObject
+(instancetype)defaultData;
+(NSArray*)keytoFetch;
@property(retain) NSMutableArray* allItems;
@property(retain) NSMutableArray* birthdayArray;
@property(retain) NSMutableArray* anniversaryArray;
@property(retain) NSMutableArray* eventArray;
@property(retain) NSMutableArray* pastEventArray;
@property(retain) NSMutableArray* comingEventArray;

-(void)addItem:(SWCellItem*)item;
-(void)updateItem:(SWCellItem*)item;
-(void)removeItemAtIndex:(NSUInteger)index fromArray:(NSMutableArray*)array;
-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

-(void)saveEventData;
-(void)loadEventData;

-(NSArray*)itemsWithIdentifer:(NSString*)identifer;
-(void)deleteItemsWithIdentifer:(NSString*)identifer;
-(void)updateItemsWithContact:(CNContact*)contact;

-(void)schelduleLocalNotification;

-(void)test;
-(void)displayError:(NSError*)error;
@end
