//
//  AppDelegate.m
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "FrameworksViewController.h"
#import "GAI.h"
#import "OSCDStackManager.h"
#import "Constants.h"

@implementation AppDelegate

-(instancetype)init {
    self = [super init];
    if (self)
    {
        [[OSCDStackManager sharedManager] setUbiquityContainerKey:UBIQUITY_CONTAINER_KEY];
        [[OSCDStackManager sharedManager] setUbiquityIDToken:UBID_TOKEN];
        [[OSCDStackManager sharedManager] setCloudPreferenceKey:COMPANY_ID "." APP_NAME "." CLOUD_PREFERENCE_KEY];
        [[OSCDStackManager sharedManager] setCloudPreferenceSet:COMPANY_ID "." APP_NAME "." CLOUD_PREFERENCE_SET];
        [[OSCDStackManager sharedManager] setMakeBackupPreferenceKey:COMPANY_ID "." APP_NAME "." BACKUP_PREFERENCE_KEY];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(getenv("NSZombieEnabled")) {
        NSLog(@"NSZombieEnabled enabled!");
    }
    NSLog(@"NSZombieEnabled enabled!");
    
    NSDictionary *appDefaults = @{SETTINGS_COLOR_SCHEME_KEY : @"Dark",SETTINGS_FTP : @"www.example.com",SETTINGS_FTP_USERNAME : @"Username", SETTINGS_FTP_PASSWORD : @"Password"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    [[OSCDStackManager sharedManager] setVersion];
    
    [[OSCDStackManager sharedManager] checkUserICloudPreferenceAndSetupIfNecessary];    // Override point for customization after application launch.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = (splitViewController.viewControllers).lastObject;
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        
        self.masterViewController = (MasterViewController *)masterNavigationController.topViewController;
        self.masterViewController.managedObjectContext = [OSCDStackManager sharedManager].managedObjectContext;
        
    }
    else{
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = [OSCDStackManager sharedManager].managedObjectContext;
        
    }
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [GAI sharedInstance].logger.logLevel = kGAILogLevelVerbose;
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-47018925-1"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[OSCDStackManager sharedManager] saveDocument];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[OSCDStackManager sharedManager] performApplicationWillEnterForegroundCheck];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[OSCDStackManager sharedManager] saveContext];
}


@end
