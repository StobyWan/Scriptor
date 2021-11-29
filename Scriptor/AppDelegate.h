//
//  AppDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_NAME                            @"Scriptor"
#define COMPANY_ID                          @"com.bryanstoberdesign"
#define TEAM_ID                             @"3W7GMD637Q"
#define SQLITE_FILE_EXTENSION               @"sqlite"
#define APP_ID                              COMPANY_ID@"."APP_NAME
#define UBIQUITY_CONTAINER_KEY              TEAM_ID@"."COMPANY_ID@"." APP_NAME
#define UBID_TOKEN                          APP_ID@".UbiquityIdentityToken"
#define CLOUD_PREFERENCE_KEY                "UseiCloudStorage"
#define CLOUD_PREFERENCE_SET                "iCloudStoragePreferenceSet"
#define BACKUP_PREFERENCE_KEY               "MakeBackup"

@class MasterViewController;
@class DetailViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@end
