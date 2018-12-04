//
//  AppDelegate.m
//  Reminder
//
//  Created by Shelton on 8/3/17.
//  Copyright © 2017 Ephnic. All rights reserved.
//

#import "AppDelegate.h"
#import "ReminderData.h"
#import <UserNotifications/UserNotifications.h>
#import <CloudKit/CloudKit.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSLog(@"%@...",launchOptions);
    // Register for push notifications
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    UIDevice* dev = [UIDevice currentDevice];
    float version = atof([dev.systemVersion UTF8String]);
    if (version < 10) {
        UIUserNotificationType types;
        UIUserNotificationSettings *settings;
        
        types = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else{

#if 1
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"UNUserNotificationCenter authorization completed.");
        }];
#endif
    }

    application.applicationIconBadgeNumber = 0;
    
    

    return YES;
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@",error);
    [[ReminderData defaultData] displayError:error];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@",deviceToken);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
//        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID];
        
        NSLog(@"%@",cloudKitNotification.alertBody);
        [[ReminderData defaultData] loadEventData];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[ReminderData defaultData] saveEventData];
    [[ReminderData defaultData] schelduleLocalNotification];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewData" object:self];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    [NSKeyedArchiver archiveRootObject:[ReminderData defaultData].eventArray toFile:@"eventArray"];
}


@end
