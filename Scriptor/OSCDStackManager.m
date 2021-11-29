//
//  OSDocumentManager.m
//  Common
//
//  Created by Duncan Groenewald on 15/07/13.
//  Copyright (c) 2013 Duncan Groenewald. All rights reserved.
//


#import "OSCDStackManager.h"
//#import "OSManagedDocument.h"


NSString* const ICloudStateUpdatedNotification = @"ICloudStateUpdatedNotification";

NSString* const OSFileDeletedNotification = @"OSFileDeletedNotification";
NSString* const OSFileCreatedNotification = @"OSFileCreatedNotification";
NSString* const OSFileClosedNotification = @"OSFileClosedNotification";
NSString* const OSFilesUpdatedNotification = @"OSFilesUpdatedNotification";
NSString* const OSDataUpdatedNotification = @"OSCoreDataUpdated";
NSString* const OSStoreChangeNotification = @"OSCoreDataStoreChanged";

// The name of the file that contains the store identifier.
static NSString *DocumentMetadataFileName = @"DocumentMetadata.plist";

// The name of the file package subdirectory that contains the Core Data store when local.
static NSString *StoreDirectoryComponentLocal = @"StoreContent";

// The name of the file package subdirectory that contains the Core Data store when in the cloud. The Core Data store itself should not be synced directly, so it is placed in a .nosync directory.
static NSString *StoreDirectoryComponentCloud = @"StoreContent.nosync";

static NSString *StoreFileName = @"persistentStore";


static OSCDStackManager* __sharedManager;

// Just a class to store details of a file.
@implementation FileRepresentation

- (instancetype)initWithFileName:(NSString *)fileName url:(NSURL *)url {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _url = url;
        _fileDate = @"";
        _percentDownloaded = nil;
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName url:(NSURL *)url date:(NSString*)fileDate {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _url = url;
        _fileDate = fileDate;
        _percentDownloaded = nil;
    }
    
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName url:(NSURL *)url percentDownloaded:(NSNumber*)percent {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _url = url;
        _fileDate = @"";
        _percentDownloaded = percent;
        _fileDate = [self modifiedDate];
    }
    
    return self;
}

- (BOOL)isEqual:(FileRepresentation*)object {
    return [object isKindOfClass:[FileRepresentation class]] && [_fileName isEqual:object.fileName];
}

- (NSString*)modifiedDate {
    NSError *er = nil;
    NSDate *date = nil;
    if ([_url getResourceValue:&date forKey:NSURLContentModificationDateKey error:&er] == YES)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        return [dateFormatter stringFromDate:date];
    } else {
        return @"" ;
    }
}

@end



@implementation OSCDStackManager
{
    BOOL _isCloudEnabled;
    NSURL* _dataDirectoryURL;
}

@synthesize isCloudEnabled = _isCloudEnabled;
@synthesize dataDirectoryURL = _dataDirectoryURL;
@synthesize ubiquityID = _ubiquityID;

+ (OSCDStackManager*)sharedManager {
    if (!__sharedManager) {
        __sharedManager = [[OSCDStackManager alloc] init];
    }
    
    return __sharedManager;
}

- (instancetype)init {
    if ((self = [super init])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserICloudPreferenceAndSetupIfNecessary) name:NSUbiquityIdentityDidChangeNotification object:nil];
        
        // We store everything locally
        [self updateFileStorageContainerURL];
        
        // Used during development to delete all files off a device
        //if (_clearFiles)
        //    [self clearAllFiles];
        _isBusy = NO;
    }
    return self;
}
+ (NSString *)persistentStoreName {
    return @"persistentStore";
}
+ (NSString *)icloudPersistentStoreName {
    return @"persistentStore_ICLOUD";
}
- (NSURL *)icloudStoreURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[OSCDStackManager icloudPersistentStoreName]];
}
- (NSURL *)backupStoreURL {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];

    
    NSString *fileName = [NSString stringWithFormat:@"%@_Backup_%@",[OSCDStackManager persistentStoreName], dateString];
    
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:fileName];
}
- (NSURL *)localUbiquitySupportURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataUbiquitySupport"];
}
/*! Returns the CoreData directory in the ubiquity container
 
 @returns The URL for the CoreData directory in ubiquity container
 */
- (NSURL *)icloudContainerURL {

    NSURL *iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:_ubiquityID];
    return [[iCloudURL URLByAppendingPathComponent:@"CoreData"] URLByAppendingPathComponent:[OSCDStackManager icloudPersistentStoreName]];
}

- (NSURL *)localStoreURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[OSCDStackManager persistentStoreName]];
}

- (void)setUbiquityID:(NSString*)ubiquityID {
    _ubiquityID = ubiquityID;
}
/*! Posts a notification that files have been changed
 */
- (void)postFileUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSFilesUpdatedNotification
                                                        object:self];
}
/*! Posts a notification that file has been deleted
 */
- (void)postFileDeletedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSFileDeletedNotification
                                                        object:self];
}
/*! Posts a notification that file has been deleted
 */
- (void)postFileCreatedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSFileCreatedNotification
                                                        object:self];
}
/*! Posts a notification that file has been deleted
 */
- (void)postFileClosedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSFileClosedNotification
                                                        object:self];
}
/*!  This method is called when the user selects whether they want to delete any files from the device in response to disabling iCloud
    for the app
 
    @param deleteICloudFiles A bool value YES or NO.  Used in combination with setIsCloudEnabled to take actions to copy files to/from iCloud
 */
- (void)setDeleteICloudFiles:(BOOL)deleteICloudFiles {
    _deleteICloudFiles = deleteICloudFiles;
}
/*! This gets called to enable or disable use of iCloud.  This is only called when the App specific setting is changed
    because if its the global setting we don't do anything anyway.  If the global iCloud setting is turned OFF then the app 
    would already have lost access to iCloud so we can't migrate files to local storage.
    If the global iCloud setting is set to ON then we need to check if the local setting is set to ON or OFF before we do anything.
 
    When iCloud is enabled then this function triggers the sharing of any local files to iCloud by migrating the files using [PSC migratePersistentStore]
    At the same time this function will trigger the metadata scan for iCloud files so that any files in iCloud appear locally.  For these iCloud files to 
    appear locally we have to build local stores from the iCloud transaction logs using standard [PSC addPersistentStore].
 
    When iCloud option is disabled we need to migrate the iCloud stores to local stores and then remove the stores from iCloud.
 
    @param  isCloudEnabled A bool value YES or NO indicating whether iCloud is enabled or disabled.
 */
- (void)setIsCloudEnabled:(BOOL)isCloudEnabled {
    FLOG(@"setIsCloudEnabled:%@ called", (isCloudEnabled ? @"YES" : @"NO"));
    
    _isCloudEnabled = isCloudEnabled;
    
    [self migrateFilesIfRequired];

}
/*! Migrates any files based on the current settings.
 
 */
- (void)migrateFilesIfRequired {
    FLOG(@"migrateFilesIfRequired called...");
    // Setting has changed to take the appropriate action
    
    if (_isCloudEnabled) {
        // iCloud has been enabled so migrate local files to iCloud
        FLOG(@" iCloud has been enabled so migrate local files to iCloud if they exist");
        
        if ([self localStoreExists]) {
            FLOG(@" Local store exists so migrate it");
            
            if ([self migrateLocalFileToICloud]) {
                FLOG(@" Local store migrated to iCloud successfully");
                self.storeURL = [self icloudStoreURL];
                
            } else {
                FLOG(@" Local store migration to iCloud FAILED because iCloud store already there");
                
                // Do nothing because we have posted an alert asking the user what to do and we will respond to that
                self.storeURL = nil;
            }
            
        } else {
            FLOG(@" No local store exists");
            self.storeURL = [self icloudStoreURL];
        }
        
    } else {
        // iCloud has been disabled so check whether to keep or delete them
        FLOG(@" iCloud has been disabled so check if there are any iCloud files and delete or migrate them");
        
            if ([self iCloudStoreExists]) {
                FLOG(@" iCloud store exists");
                
                if (_deleteICloudFiles) {
                    FLOG(@" delete iCloud Files");
                    // DG Need to add Code for this !
                    [self removeICloudStore];
                    [self deregisterForStoreChanges];
                    _persistentStoreCoordinator = nil;
                    _managedObjectContext = nil;
                    self.storeURL = [self localStoreURL];
                } else {
                    FLOG(@" migrate iCloud Files");
                    if ([self migrateICloudFileToLocal]) {
                        FLOG(@" iCloud store migrated to Local successfully");
                        self.storeURL = [self localStoreURL];
                    } else {
                        FLOG(@" iCloud store migration to Local FAILED");
                        self.storeURL = nil;
                    }
                }
            } else {
                FLOG(@" no iCloud store exists so no migration required");
                self.storeURL = [self localStoreURL];
            }
    }
    
}
/*! Migrates and iCloud file to a Local file by creating a OSManagedDocument
    and calling the moveDocumentToLocal method.  The document knows how to move itself.
 
    @param fileURL The URL of the file to be moved
 */
- (BOOL)migrateICloudFileToLocal {
    FLOG(@" migrateICloudFileToLocal");
    
    
    // Now check if the file is in iCloud
    if (![self localStoreExists]) {
        
        return [self moveStoreToLocal];
        
    } else {
        
        FLOG(@" error migrateICloudFileToLocal because Local file already exists!");
        return NO;
        
    }
}

/*! Migrates a Local file to iCloud file by creating a OSManagedDocument
 and calling the moveDocumentToICloud method.  The document knows how to move itself.
 
 @param fileURL The URL of the file to be moved
 */
- (bool)migrateLocalFileToICloud {
    FLOG(@" migrateLocalFileToiCloud");
    
    // Now check if the file is already in iCloud
    if (![self iCloudStoreExists]) {
        
        return [self moveStoreToICloud];
        
    } else {
        
        FLOG(@" error migrating local file to iCloud because iCloud file already exists!");
        
        _cloudMergeChoiceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_manager_alert_file_exist_title", @"iCloud file exists")  message:NSLocalizedString(@"stack_manager_alert_file_exist_message", @"Do you want to merge the data on this device with the existing iCloud data?")  delegate:self cancelButtonTitle:NSLocalizedString(@"stack_manager_alert_file_exist_button_no", @"No")  otherButtonTitles:NSLocalizedString(@"stack_manager_alert_file_exist_button_yes", @"Yes") , nil];
        [_cloudMergeChoiceAlert show];

        return NO;
        
    }
}

/*! Checks for the existence of any documents with _UUID_ in the filename.  These documents are documents shared in
    iCloud.  Returns YES if any are found.
 
    @return Returns YES of any documents are found or NO if none are found.
 */
- (bool)iCloudStoreExists {
    FLOG(@"iCloudStoreExists called");
    
    FLOG(@"  icloudStoreURL is %@", [[self icloudContainerURL] path]);
    
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self icloudContainerURL].path isDirectory:&isDir];
    
    FLOG(@"  icloudContainerURL %@", (fileExists ? @"exists" : @"does not exist"));
    
    return fileExists;
}
/*! Checks for the existence of any documents without _UUID_ in the filename.  These documents are local documents only.  Returns YES if any are found.
 
 @return Returns YES of any documents are found or NO if none are found.
 */
- (bool)localStoreExists {
    FLOG(@"localStoreExists called");
    
    FLOG(@"  localStoreURL is %@", [[self localStoreURL] path]);
    BOOL isDir;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self localStoreURL].path isDirectory:&isDir];
    
    FLOG(@"  localStoreURL %@", (fileExists ? @"exists" : @"does not exist"));
    
    return fileExists;
}

/*! Returns the CoreData directory in the ubiquity container
 
    @returns The URL for the CoreData directory in ubiquity container
 */
- (NSURL*)iCloudCoreDataURL {
    NSURL *iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:_ubiquityID];
    return [iCloudURL URLByAppendingPathComponent:@"CoreData"];
}

/*! Returns the /Documents directory for the app
 
    @returns Returns the URL for the apps /Documents directory
 */
- (NSURL*)documentsDirectoryURL {
    _dataDirectoryURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    return [_dataDirectoryURL URLByAppendingPathComponent:@"Documents"];
}

- (void)updateFileStorageContainerURL {
    // Perform the asynchronous update of the data directory and document directory URLs
    _dataDirectoryURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
}

/*! Called to determine whether the user preference "Use iCloud" has been set to YES and iCloud
    is available (user logged in and Documents & Data ON).  If this returns YES then create new files
    with UUID and iCloud options.  If this returns NO create new files without UUID or iCloud options.
 
    @return Returns YES if both app iCloud "Use iCloud" preferences is YES and iCloud is available.
 */
- (bool)canUseICloud {
    
    // Get the user preference setting
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    //NSString* userICloudChoiceSet = [userDefaults stringForKey:self.cloudPreferenceSet];
    
    bool userICloudChoice = [userDefaults boolForKey:self.cloudPreferenceKey];
    FLOG(@" User preference for %@ is %@", self.cloudPreferenceSet, (userICloudChoice ? @"YES" : @"NO"));
    
    if ([NSFileManager defaultManager].ubiquityIdentityToken && userICloudChoice)
        return YES;
    else
        return NO;
    
}
/*! Called to determine whether iCloud is available (user logged in and Documents & Data ON).
 
 @return Returns YES if iCloud account is active and Data & Documents is ON
 */
- (bool)isICloudAvailable {
    
    
    if ([NSFileManager defaultManager].ubiquityIdentityToken)
        return YES;
    else
        return NO;
    
}

- (bool)isBusy {
    return _isBusy;
}

// We only care if the one we have open is changing
- (void)registerForStoreChanges:(NSPersistentStoreCoordinator*)storeCoordinator {
    //LOG(@"registerForStoreChanges called");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storesWillChange:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:storeCoordinator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storesDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:storeCoordinator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storesDidImport:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:storeCoordinator];
    
}

- (void)deregisterForStoreChanges {
    //LOG(@"degisterForStoreChanges called");
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    
}
// NB - this may be called from a background thread so make sure we run on the main thread !!
// This is when store files are being switched from fallback to iCloud store
- (void)storesWillChange:(NSNotification*)n {
    FLOG(@"storesWillChange called - >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    
    // Check type of transition
    NSNumber *type = (n.userInfo)[NSPersistentStoreUbiquitousTransitionTypeKey];
    
    FLOG(@" transition type is %@", type);
    
    if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted) {
        
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted");
        
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeAccountAdded) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeAccountAdded");
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeAccountRemoved) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeAccountRemoved");
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeContentRemoved) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeContentRemoved");
    }

    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSArray *addedStores = (n.userInfo)[NSAddedPersistentStoresKey];
        NSArray *removedStores = (n.userInfo)[NSRemovedPersistentStoresKey];
        NSArray *changedStores = (n.userInfo)[NSUUIDChangedPersistentStoresKey];
        
        FLOG(@" added stores are %@", addedStores);
        FLOG(@" removed stores are %@", removedStores);
        FLOG(@" changed stores are %@", changedStores);
        
        NSError *error;
        if ((self.managedObjectContext).hasChanges) {
            [self.managedObjectContext save:&error];
        }
        
        [self.managedObjectContext reset];
        // Reset user Interface - i.e. lock the user out!
        _storesChanging = YES;
        
        //DG Turn this off for now
        //[self showStoresChangingAlert];
    }];
    
}
// NB - this may be called from a background thread so make sure we run on the main thread !!
// This is when store files are being switched from fallback to iCloud store
- (void)storesDidChange:(NSNotification*)n {
    FLOG(@"storesDidChange called - >>>>>>>>>>>>>>>>>>>>>>>>>>>>");

    // Check type of transition
    NSNumber *type = (n.userInfo)[NSPersistentStoreUbiquitousTransitionTypeKey];
    
    FLOG(@" userInfo is %@", n.userInfo);
    FLOG(@" transition type is %@", type);
    
    if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted) {
        
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeInitialImportCompleted");
        
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeAccountAdded) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeAccountAdded");
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeAccountRemoved) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeAccountRemoved");
    } else if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeContentRemoved) {
        FLOG(@" transition type is NSPersistentStoreUbiquitousTransitionTypeContentRemoved");
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        _storesChanging = NO;
        if (type.intValue == NSPersistentStoreUbiquitousTransitionTypeContentRemoved) {
            [self showStoreRemovedAlert];
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            [self postStoreChangedNotification];
            
            FLOG(@" iCloud store was removed! Wait for empty store");
        }
        // Refresh user Interface
        [self createTimer];
        
    }];
}

- (void)showStoreRemovedAlert {
    
    if (_storesUpdatingAlert == nil) {
        NSString * message =NSLocalizedString(@"stack_master_vc_alert_store_moved", @"Please wait for a new store to be created.") ;
        _storesUpdatingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_master_alert_title_store_moved", @"Store file has been removed") message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        FLOG(@" XXX showStoreRemovedAlert %@", message);
        [_storesUpdatingAlert show];
    }
    
}
// NB - this may be called from a background thread so make sure we run on the main thread !!
// This is when transactoin logs are loaded
- (void)storesDidImport:(NSNotification*)notification {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        FLOG(@"storesDidImport ");
        [self createTimer];
        /* Process new/changed objects here and remove any unwanted items or duplicates prior to merging with current context
         //
         NSSet *updatedObjectIDs = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
         NSSet *insertedObjectIDs = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
         NSSet *deletedObjectIDs = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
         
         // Iterate over all the new, changed or deleted ManagedObjectIDs and get the NSManagedObject for the corresponding ID:
         // These come from another thread so we can't reference the objects directly
         
         for(NSManagedObjectID *managedObjectID in updatedObjectIDs){
         NSManagedObject *managedObject = [_managedObjectContext objectWithID:managedObjectID];
         }
         
         // Check is some object is equal to an inserted or updated object
         if([myEntity.objectID isEqual:managedObject.objectID]){}
         */
        if (self.managedObjectContext) {
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }
        
    }];
}

- (void)createTimer {
    if (self.iCloudUpdateTimer == nil) {
        self.iCloudUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(notifyOfCoreDataUpdates)
                                                                userInfo:nil
                                                                 repeats:NO];
    } else {
        (self.iCloudUpdateTimer).fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    }
}

- (void)notifyOfCoreDataUpdates {
    FLOG(@"notifyOfCoreDataUpdates called");
    if (_storesUpdatingAlert)
        [_storesUpdatingAlert dismissWithClickedButtonIndex:0 animated:YES];

    [self.iCloudUpdateTimer invalidate];
    self.iCloudUpdateTimer = nil;
    [self postUIUpdateNotification];
}

- (void)postUIUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSDataUpdatedNotification
                                                        object:self];
}

- (void)postStoreChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:OSStoreChangeNotification
                                                        object:self];
}

- (void)documentStateChanged:(NSNotification*)notification {
    switch ([notification.object documentState]) {
        case UIDocumentStateNormal:
            //FLOG(@"UIDocumentStateNormal");
            break;
        case UIDocumentStateClosed:
            FLOG(@"UIDocumentStateClosed %@", notification);
            break;
        case UIDocumentStateInConflict:
            FLOG(@"UIDocumentStateInConflict %@", notification);
            break;
        case UIDocumentStateSavingError:
            FLOG(@"UIDocumentStateSavingError %@", notification);
            break;
        case UIDocumentStateEditingDisabled:
            FLOG(@"UIDocumentStateEditingDisabled %@", notification);
            break;
    }
}

- (void)addInitialData {
    FLOG(@"addInitialData called");
}

/*! Checks whether the ubiquity token has changed and if so it means the iCloud login has changed since the application was last
 active.  If the user has signed out then they will loose access to their iCloud documents so tell them to log back in to
 access those documents.
 
 @param currenToken The current ubiquity identity.
 */
- (void)checkUbiquitousTokenFromPreviousLaunch:(id)currentToken {
    // Fetch a previously stored value for the ubiquity identity token from NSUserDefaults.
    // That value can be compared to the current token to determine if the iCloud login has changed since the last launch of our application
    
    NSData* oldTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:_ubiquityIDToken];
    id oldToken = oldTokenData ? [NSKeyedUnarchiver unarchiveObjectWithData:oldTokenData] : nil;
    if (oldTokenData && ![oldToken isEqual:currentToken]) {
        // If we had a token, we were signed in before.
        // If the token has change, a signout has occurred - either switching to another account or deleting iCloud entirely.
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_manager_alert_icloud_sign-out_title",@"iCloud Sign-Out") message:NSLocalizedString(@"stack_manager_alert_icloud_sign-out_message",@"You have signed out of the iCloud account previously used to store documents. Sign back in to access those documents") delegate:nil cancelButtonTitle:NSLocalizedString(@"stack_manager_alert_icloud_sign-out_button",@"OK") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showMigratingAlert:(NSString*)str {
    
    if (_migratingAlert == nil) {
        NSString * message = [NSString stringWithFormat:NSLocalizedString(@"stack_manager_alert_migration_icloud_message", @"Please wait while your files get migrated %@ iCloud"), str];
        _migratingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_manager_alert_migration_icloud_title",  @"File migration in progress") message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        FLOG(@" XXX showMigratingAlert %@", message);
        [_migratingAlert show];
    }

}

- (void)dismissMigratingAlert {
    if (_migratingAlert != nil) {
        FLOG(@" XXX dismissMigratingAlert");
        [_migratingAlert dismissWithClickedButtonIndex:0 animated:YES];
        _migratingAlert = nil;
    }
}

#pragma mark - AlertView Dissmiss Alert Delegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == _cloudChoiceAlert)
    {
        FLOG(@" _cloudChoiceAlert being processed");
        if (buttonIndex == 1) {
            FLOG(@" user selected iCloud files");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:_cloudPreferenceKey];
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:_cloudPreferenceSet];
            _useICloudStorage = YES;
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setIsCloudEnabled:YES];
            [self postFileUpdateNotification];
        }
        else {
            FLOG(@" user selected local files");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_cloudPreferenceKey];
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:_cloudPreferenceSet];
            _useICloudStorage = NO;
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self setIsCloudEnabled:NO];
        }
    }
    if (alertView == _cloudChangedAlert)
    {   FLOG(@" _cloudChangedAlert being processed");
        if (buttonIndex == 0) {
            FLOG(@" 'Keep using iCloud' selected");
            FLOG(@" turn Use iCloud back ON");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:_cloudPreferenceKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _useICloudStorage = YES;
            [self setIsCloudEnabled:YES];
            
        }
        else if (buttonIndex == 1) {
            FLOG(@" 'Keep on My iPhone' selected");
            FLOG(@" copy to local storage");
            _useICloudStorage = NO;
            [self setDeleteICloudFiles:NO];
            [self setIsCloudEnabled:NO];
            
        }else if (buttonIndex == 2) {
            FLOG(@" 'Delete from My iPhone' selected");
            FLOG(@" delete copies from iPhone");
            _useICloudStorage = NO;
            [self setDeleteICloudFiles:YES];
            [self setIsCloudEnabled:NO];
        }
        [self postFileUpdateNotification];
    }
    if (alertView == _cloudMergeChoiceAlert)
    {
        FLOG(@" _cloudMergeChoiceAlert being processed");
        if (buttonIndex == 0) {
            FLOG(@" user selected to use iCloud file");
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            self.storeURL = [self icloudStoreURL];
            [self deleteLocalStore];
            [self postStoreChangedNotification];
        }
        else {
            FLOG(@" user selected to merge with iCloud file");
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            [self moveStoreToICloud];
            [self postStoreChangedNotification];
        }
    }

}


- (void)storeCurrentUbiquityToken:(id)currentToken {
    // Write the ubquity identity token to NSUserDefaults if it exists.
    // Otherwise, remove the key.
    
    if (currentToken) {
        NSData* newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentToken];
        [[NSUserDefaults standardUserDefaults] setObject:newTokenData forKey:_ubiquityIDToken];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:_ubiquityIDToken];
    }
}

- (bool)userICloudChoice {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    
    NSString* userICloudChoiceSet = [userDefaults stringForKey:_cloudPreferenceSet];
    bool userICloudChoice = [userDefaults boolForKey:_cloudPreferenceKey];
    
    userICloudChoice = [userDefaults boolForKey:_cloudPreferenceKey];
    
    if (userICloudChoiceSet.length == 0)
        return NO;
    else
        return userICloudChoice;

}
/*! Checks to see whether the user has previously selected the iCloud storage option, and if so then check
 whether the iCloud identity has changed (i.e. different iCloud account being used or logged out of iCloud).
 
 If the user has previously chosen to use iCloud and we're still signed in, setup the CloudManager
 with cloud storage enabled.
 
 If iCloud is available AND if no user choice is recorded, use a UIAlert to fetch the user's preference.
 
 If iCloud is available AND if user has selected to Use iCloud then check if any local files need to be
 migrated.
 
 if iCloud is available AND if user has selected to NO Use iCloud then check if any iCloud files need to
 be migrated to local storage.
 
 */
- (void)checkUserICloudPreferenceAndSetupIfNecessary {
    FLOG(@"checkUserICloudPreferenceAndSetupIfNecessary called");
    
    // Check if a backup has been requested
    [self backupCurrentStore];

    self.ubiquityID = _ubiquityContainerKey ;

    id currentToken = [NSFileManager defaultManager].ubiquityIdentityToken;

    if (!currentToken) {
        FLOG(@" iCloud is not enabled");
        // If there is no token now, set our state to NO
        self.isCloudEnabled = NO;
    } else {
        FLOG(@" iCloud is enabled");
        if (self.isCloudEnabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ICloudStateUpdatedNotification object:nil];
        }
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userICloudChoiceSet = [userDefaults stringForKey:_cloudPreferenceSet];
    
    bool userICloudChoice = [userDefaults boolForKey:_cloudPreferenceKey];
    
    userICloudChoice = [userDefaults boolForKey:_cloudPreferenceKey];
    
    FLOG(@" User preference for %@ is %@", _cloudPreferenceKey, (userICloudChoice ? @"YES" : @"NO"));
    
    if (userICloudChoice) {
        
        FLOG(@" User selected iCloud");
        _useICloudStorage = YES;
        
        // Display notice if previous iCloud account is not available
        [self checkUbiquitousTokenFromPreviousLaunch:currentToken];
        
        
    } else {
        
        FLOG(@" User disabled iCloud");
        _useICloudStorage = NO;
        
    }
    
    // iCloud is active
    if (currentToken) {
        
        FLOG(@" iCloud is active");
        
        // If user has not yet set preference then prompt for them to select a preference
        if (userICloudChoiceSet.length == 0) {
            
            FLOG(@" userICloudChoiceSet has not been set yet, so set default to NO.");
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_cloudPreferenceKey];
            [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:_cloudPreferenceSet];
            _useICloudStorage = NO;
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self setIsCloudEnabled:NO];
            
            _cloudChoiceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_manager_alert_icloud_choice_title", @"Choose Storage Option")  message:NSLocalizedString(@"stack_manager_alert_icloud_choice_message",@"Should documents be stored in iCloud or on just this device?") delegate:self cancelButtonTitle:NSLocalizedString(@"stack_manager_alert_icloud_choice_button_1",@"Local only") otherButtonTitles:NSLocalizedString(@"stack_manager_alert_icloud_choice_button_2",@"iCloud"), nil];
            [_cloudChoiceAlert show];
            
        }
        else {
            FLOG(@" userICloudChoiceSet is set");
            if (userICloudChoice) {
                FLOG(@" userICloudChoice is YES");
                // iCloud is available and user has selected to use it
                // Check if any local files need to be migrated to iCloud
                // and migrate them
                [self setIsCloudEnabled:YES];
                
            } else  {
                FLOG(@" userICloudChoice is NO");
                // iCloud is available but user has chosen to NOT Use iCloud
                // Check that NO local file exists already
                 if (![self localStoreExists]) {
                    // and IF an iCloud file exists
                    if ([self iCloudStoreExists]) {
                        FLOG(@" iCloudStoreExists exists");
                    
                    //  Ask the user if they want to migrate the iCloud file to a local file
                    [self promptUserAboutICloudDocumentStorage];
                    
                    } else {
                        // Otherwise just set iCloud enabled
                        [self setIsCloudEnabled:NO];
                    }
                 } else {
                     // A Local file already exists so what to do ?
                     // Just tell the user a file has been detected in iCloud
                     // and ask if they want to start using the iCloud file
                     [self setIsCloudEnabled:NO];
                 }
            }
            
        }
    }
    else {
        FLOG(@" iCloud is not active");
        [self setIsCloudEnabled:NO];
        _useICloudStorage = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_cloudPreferenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Since the user is signed out of iCloud, reset the preference to not use iCloud, so if they sign in again we will prompt them to move data
        [userDefaults removeObjectForKey:_cloudPreferenceSet];
    }
    
    [self storeCurrentUbiquityToken:currentToken];
}
/*! This method is called when Use iCloud preference has been turned OFF to ask the user whether they want to keep iCloud files, delete them or keep using iCloud
 
 */
- (void)promptUserAboutICloudDocumentStorage {
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _cloudChangedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_master_alert_icloud_disabled_title",@"You're not using iCloud") message:@"What would you like to do with documents currently on this phone?" delegate:self cancelButtonTitle:@"Keep using iCloud" otherButtonTitles:@"Keep on My iPhone", @"Delete from My iPhone", nil];
    } else {
        _cloudChangedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"stack_master_alert_icloud_disabled_title",@"You're not using iCloud") message:NSLocalizedString(@"stack_master_alert_icloud_disabled_message",@"What would you like to do with documents currently on this phone?") delegate:self cancelButtonTitle:NSLocalizedString(@"stack_master_alert_icloud_disabled_button_1",@"Keep using iCloud") otherButtonTitles:NSLocalizedString(@"stack_master_alert_icloud_disabled_button_2",@"Keep on My iPad"),NSLocalizedString(@"stack_master_alert_icloud_disabled_button_3", @"Delete from My iPad"), nil];
        
    }
    
    [_cloudChangedAlert show];
}

- (void)performApplicationWillEnterForegroundCheck {
    FLOG(@"applicationWillEnterForegroundCheck called");
    
    // Check if a backup has been requested
    [self backupCurrentStore];
    
    // Check if the app settings have been changed in the Settings Bundle (we use a Settings Bundle which
    // shows settings in the Devices Settings app, along with all the other device settings).
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    bool userICloudChoice = [userDefaults boolForKey:_cloudPreferenceKey];
    
    
    // Check if iCloud is available, if its not then we can't do anything anyway
    
    if ([self isICloudAvailable]) {
        
        // iCloud option has been turned off
        if (!userICloudChoice) {
            
            // If iCloud files still exist then ask what to do
            if ([self iCloudStoreExists]) {
                /*
                _useICloudStorage = NO;
                [self setDeleteICloudFiles:NO];
                [self setIsCloudEnabled:NO];
                */
                [self promptUserAboutICloudDocumentStorage];
                
            } else {
                [self setIsCloudEnabled:NO];
            }
            // Handle the users response in the alert callback
            
        } else {
            
            // iCloud is turned on so just copy them across... including the one we may have open
            
            //LOG(@" iCloud turned on so copy any created files across");
            [self setIsCloudEnabled:YES];  // This does all the work for us
            
            _useICloudStorage = YES;
            
        }
    }
    // Update the list 
    [self postFileUpdateNotification];
}

- (void)closeDocument {
    //FLOG(@"closeDocument called.");
    [self saveContext];
    
    [self deregisterForStoreChanges];
    
}

- (void)saveDocument {
    [self saveContext];
}

//////////
/*! Moves a local document to iCloud by migrating the existing store to iCloud and then removing the original store.
    We use a local file name of persistentStore and an iCloud name of persistentStore_ICLOUD so its easy to tell if
    the file is iCloud enabled
 
 */
- (bool)moveStoreToICloud {
    FLOG(@"moveStoreToICloud called");
    
    // Always make a backup of the local store before migrating to iCloud
    [self backupLocalStore];
    
    NSPersistentStoreCoordinator *migrationPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    // Open the store
    id sourceStore = [migrationPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self localStoreURL] options:[self localStoreOptions] error:nil];
    
    if (!sourceStore) {
        
        FLOG(@" failed to add old store");
        return FALSE;
    } else {
        FLOG(@" Successfully added store to migrate");
        
//        bool moveSuccess = NO;
        NSError *error;
        
        FLOG(@" About to migrate the store...");
        id migrationSuccess = [migrationPSC migratePersistentStore:sourceStore toURL:[self icloudStoreURL] options:[self icloudStoreOptions] withType:NSSQLiteStoreType error:&error];
        
        if (migrationSuccess) {
//            moveSuccess = YES;
            FLOG(@"store successfully migrated");
            [self deregisterForStoreChanges];
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            self.storeURL = [self icloudStoreURL];
            // Now delete the local file
            [self deleteLocalStore];            
            return TRUE;
        }
        else {
            FLOG(@"Failed to migrate store: %@, %@", error, error.userInfo);
            return FALSE;
        }
        
    }
    return FALSE;
}
/*! Moves an iCloud store to local by migrating the iCloud store to a new local store and then removes the store from iCloud.
 
 Note that even if it fails to remove the iCloud files it deletes the local copy.  User may need to clean up orphaned iCloud files using a Mac!
 
 @return Returns YES of file was migrated or NO if not.
 */
- (bool)moveStoreToLocal {
    FLOG(@"moveStoreToLocal called");
    
    // Lets use the existing PSC
    NSPersistentStoreCoordinator *migrationPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    // Open the store
    id sourceStore = [migrationPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self icloudStoreURL] options:[self icloudStoreOptions] error:nil];
    
    if (!sourceStore) {
        
        FLOG(@" failed to add old store");
        return FALSE;
    } else {
        FLOG(@" Successfully added store to migrate");
        
//        bool moveSuccess = NO;
        NSError *error;
        
        FLOG(@" About to migrate the store...");
        id migrationSuccess = [migrationPSC migratePersistentStore:sourceStore toURL:[self localStoreURL] options:[self localStoreOptions] withType:NSSQLiteStoreType error:&error];
        
        if (migrationSuccess) {
//            moveSuccess = YES;
            FLOG(@"store successfully migrated");
            [self deregisterForStoreChanges];
            _persistentStoreCoordinator = nil;
            _managedObjectContext = nil;
            self.storeURL = [self localStoreURL];
            [self removeICloudStore];
        }
        else {
            FLOG(@"Failed to migrate store: %@, %@", error, error.userInfo);
            return FALSE;
        }
        
    }

    return TRUE;
}

- (void)removeICloudStore {
    BOOL result;
    NSError *error;
    // Now delete the iCloud content and file
    result = [NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:[self icloudStoreURL]
                                                                                  options:[self icloudStoreOptions]
                                                                                    error:&error];
    if (!result) {
        FLOG(@" error removing store");
        FLOG(@" error %@, %@", error, error.userInfo);
        return ;
    } else {
        FLOG(@" Core Data store removed.");
        
        // Now delete the local file
        [self deleteLocalCopyOfiCloudStore];
        
        return ;
    }
    
}

//Check the User setting and if a backup has been requested make one and reset the option
- (bool)backupCurrentStore {
    FLOG(@"backupCurrentStore called");
    
    if (!_makeBackupPreferenceKey) {
        FLOG(@" error _makeBackupPreferenceKey not set!");
        return FALSE;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    bool makeBackup = [userDefaults boolForKey:_makeBackupPreferenceKey];
    
    if (!makeBackup) {
        return FALSE;
    }

    if ([self userICloudChoice] && [self iCloudStoreExists]) {
        [self backupICloudStore];
    } else if (![self userICloudChoice] && [self localStoreExists]) {
        [self backupLocalStore];
    }
    
    return FALSE;
}

/*! Creates a backup of the ICloud store
 
 @return Returns YES of file was migrated or NO if not.
 */
- (bool)backupICloudStore {
    FLOG(@"backupICloudStore called");
    
    
    // Lets use the existing PSC
    NSPersistentStoreCoordinator *migrationPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    // Open the store
    id sourceStore = [migrationPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self icloudStoreURL] options:[self icloudStoreOptions] error:nil];
    
    if (!sourceStore) {
        
        FLOG(@" failed to add old store");
        migrationPSC = nil;
        return FALSE;
    } else {
        FLOG(@" Successfully added store to migrate");
        
        NSError *error;
        
        FLOG(@" About to migrate the store...");
        id migrationSuccess = [migrationPSC migratePersistentStore:sourceStore toURL:[self backupStoreURL] options:[self localStoreOptions] withType:NSSQLiteStoreType error:&error];
        
        if (migrationSuccess) {
            FLOG(@"store successfully backed up");
            migrationPSC = nil;
            // Now reset the backup preference
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_makeBackupPreferenceKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return TRUE;
        }
        else {
            FLOG(@"Failed to backup store: %@, %@", error, error.userInfo);
            migrationPSC = nil;
            return FALSE;
        }
        
    }
    migrationPSC = nil;
    return FALSE;
}
/*! Creates a backup of the ICloud store
 
 @return Returns YES of file was migrated or NO if not.
 */
- (bool)backupLocalStore {
    FLOG(@"backupLocalStore called");
    
    
    // Lets use the existing PSC
    NSPersistentStoreCoordinator *migrationPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    // Open the store
    id sourceStore = [migrationPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self localStoreURL] options:[self localStoreOptions] error:nil];
    
    if (!sourceStore) {
        
        FLOG(@" failed to add old store");
        migrationPSC = nil;
        return FALSE;
    } else {
        FLOG(@" Successfully added store to migrate");
        
        NSError *error;
        
        FLOG(@" About to migrate the store...");
        id migrationSuccess = [migrationPSC migratePersistentStore:sourceStore toURL:[self backupStoreURL] options:[self localStoreOptions] withType:NSSQLiteStoreType error:&error];
        
        if (migrationSuccess) {
            FLOG(@"store successfully backed up");
            migrationPSC = nil;
            // Now reset the backup preference
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:_makeBackupPreferenceKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return TRUE;
        }
        else {
            FLOG(@"Failed to backup store: %@, %@", error, error.userInfo);
            migrationPSC = nil;
            return FALSE;
        }
        
    }
    migrationPSC = nil;
    return FALSE;
}
// In this case we are deleting the local copy of an iCloud document in response
// to detecting that the iCloud file has been removed. We need to do
// the following:
// 1.  Delete the local /CoreDataUbiquitySupport directory using a FileCoordinator or it won't always be
//     removed properly!
//
- (void)deleteLocalCopyOfiCloudStore {
    // We need to get the URL to the store
    FLOG(@"deleteLocalCopyOfiCloudStore called ");
    
    NSURL *coreDataSupportFiles = [self localUbiquitySupportURL];
    
    //Check is this is removing the file we are currently migrating
    FLOG(@" Deleting file %@", coreDataSupportFiles);
    
    // Check if the CoreDataUbiquitySupport files exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:coreDataSupportFiles.path]) {
        FLOG(@" CoreDataUbiquitySupport files do not exist");
        coreDataSupportFiles = nil;
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        
        [fileCoordinator coordinateWritingItemAtURL:coreDataSupportFiles options:NSFileCoordinatorWritingForDeleting
                                              error:nil byAccessor:^(NSURL* writingURL) {
                                                  NSFileManager* fileManager = [[NSFileManager alloc] init];
                                                  NSError *er;
                                                  //FLOG(@" deleting %@", writingURL);
                                                  bool res = [fileManager removeItemAtURL:writingURL error:&er];
                                                  if (res) {
                                                      FLOG(@"   CoreDataSupport files removed");
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                          
                                                          [self postFileUpdateNotification];
                                                          [self postStoreChangedNotification];
                                                      }];
                                                  }
                                                  else {
                                                      FLOG(@"   CoreDataSupport files  NOT removed");
                                                      FLOG(@"   error %@, %@", er, er.userInfo);
                                                  }
                                              }];
        
    });
    
    return;
}
// In this case we are deleting the local copy of an iCloud document in response
// to detecting that the iCloud file has been removed. We need to do
// the following:
// 1.  Delete the local /CoreDataUbiquitySupport directory using a FileCoordinator or it won't always be
//     removed properly!
//
- (void)deleteLocalStore {
    // We need to get the URL to the store
    FLOG(@"deleteLocalStore called ");
    
    NSURL *fileURL = [self localStoreURL];
    
    //Check is this is removing the file we are currently migrating
    FLOG(@" Deleting file %@", fileURL);
    
    // Check if the CoreDataUbiquitySupport files exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
        FLOG(@" Local store file does not exist");
        fileURL = nil;
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        
        [fileCoordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingForDeleting
                                              error:nil byAccessor:^(NSURL* writingURL) {
                                                  NSFileManager* fileManager = [[NSFileManager alloc] init];
                                                  NSError *er;
                                                  //FLOG(@" deleting %@", writingURL);
                                                  bool res = [fileManager removeItemAtURL:writingURL error:&er];
                                                  if (res) {
                                                      FLOG(@"   Local store file removed");
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                          
                                                          [self postFileUpdateNotification];
                                                          [self postStoreChangedNotification];
                                                      }];
                                                  }
                                                  else {
                                                      FLOG(@"   Local store file  NOT removed");
                                                      FLOG(@"   error %@, %@", er, er.userInfo);
                                                  }
                                              }];
        
    });
    
    return;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (void)createManagedObjectContext {
    if (_managedObjectContext != nil) {
        return ;
    }

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }

}
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Scriptor" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (self.storeURL == nil) {
        FLOG(@" error storeURL is nil!");
        return nil;
    }
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:self.storeOptions error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        FLOG(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self registerForStoreChanges:_persistentStoreCoordinator];
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}
// Returns the local store options
- (NSDictionary*)localStoreOptions {
    return @{NSMigratePersistentStoresAutomaticallyOption:@YES,
             NSInferMappingModelAutomaticallyOption:@YES,
             NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE" }};
}
// Returns the iCloud store options
- (NSDictionary*)icloudStoreOptions {
    
    NSString *icloudFilename = [NSString stringWithFormat:@"%@_ICLOUD", [OSCDStackManager persistentStoreName]];

    return @{NSPersistentStoreUbiquitousContentNameKey:icloudFilename,
             NSMigratePersistentStoresAutomaticallyOption:@YES,
             NSInferMappingModelAutomaticallyOption:@YES,
             NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE" }};
}
// Checks if the file is iCloud or Local and returns the required options
- (NSDictionary*)storeOptions {
    
    NSString *string = (self.storeURL).URLByDeletingPathExtension.lastPathComponent;
    
    // If it's an iCloud file
    if ([string rangeOfString:@"_ICLOUD"].location != NSNotFound) {
        return [self icloudStoreOptions];
        
    } else {
        return [self localStoreOptions];
        
    }
    
}

- (void)setVersion {  // this function detects what is the CFBundle version of this application and set it in the settings bundle
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  // transfer the current version number into the defaults so that this correct value will be displayed when the user visit settings page later
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    [defaults setObject:version forKey:@"version"];
    [defaults setObject:build forKey:@"build"];
}

- (NSArray *)getData:(NSString*)entityName sortField:(NSString*)sortKey predicate:(NSPredicate*)predicate {
    FLOG(@"getData called");
    
    if ([OSCDStackManager sharedManager].managedObjectContext == nil) {
        FLOG(@"Error can't continue with null managedObjectContext");
        return nil;
    }
    if (entityName == nil) {
        FLOG(@"Error can't continue with null entityName");
        return nil;
    }
    if (sortKey == nil) {  // if its not set then just set it as follows...
        FLOG(@"Error can't continue with null sortField");
        return nil;
    }
    FLOG(@" entity is %@", entityName);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[OSCDStackManager sharedManager].managedObjectContext];
    if (entity == nil) {
        FLOG(@"  error finding entity %@ in class %@", entityName, [self class]);
        return nil;
    }
    
    fetchRequest.entity = entity;
    
    if (predicate)
        fetchRequest.predicate = predicate;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    NSArray *sortDescriptors =@[sortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSError *error = nil;
    NSArray *result = [[OSCDStackManager sharedManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (!result) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
	    abort();
	}
    
    return result;
}

/*! Lists all LOCAL DOCUMENTS on a device in the local /Document directory. LOCAL DOCUMENTS are documents that have
 filenames with no _UUID_ appended to the filename
 
 @return Returns an array of local document URLs
 */
- (NSArray*)listAllLocalDocuments {
    NSURL* documentsDirectoryURL = self.documentsDirectoryURL;
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"   ");
    FLOG(@"  ALL LOCAL DOCUMENTS");
    FLOG(@"  ===================");
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSURL* document in docs) {
        NSString *name = document.lastPathComponent;
        
        if ([name rangeOfString:@"_UUID_"].location == NSNotFound && ![name isEqualToString:@".DS_Store"]) {
            FLOG(@"  %@", name);
            [array addObject:document];
        }
    }
    FLOG(@"   ");
    FLOG(@"   ");
    return array;
}
/*! Lists all ICLOUD DOCUMENTS on a device in the local /Document directory. ICLOUD DOCUMENTS are documents that have
 filenames with _UUID_ appended to the filename
 
 @return Returns an array of iCloud document URLs
 */
- (NSArray*)listAllICloudDocuments {
    NSURL* documentsDirectoryURL = self.documentsDirectoryURL;
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"   ");
    FLOG(@"  ALL ICLOUD DOCUMENTS");
    FLOG(@"  ====================");
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSURL* document in docs) {
        NSString *name = document.lastPathComponent;
        
        if ([name rangeOfString:@"_UUID_"].location != NSNotFound) {
            //FLOG(@"  %@", name);
            [array addObject:document];
        }
    }
    //FLOG(@"   ");
    //FLOG(@"   ");
    return array;
}
/*! Lists all DOCUMENTS on a device in both the local /Document directory and in the iCloud container.
 Note that DOCUMENTS are the user created UIManagedDocuments and not all the file system files. The list
 should correspond with the NSPersistentStoreUbiquitousContentNameKey used when opening the Core Data store.
 
 */
- (void)listAllDocuments {
    NSURL* documentsDirectoryURL = self.documentsDirectoryURL;
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"   ");
    FLOG(@"  ALL LOCAL DOCUMENTS (%d)", [docs count]);
    FLOG(@"  ====================");
    FLOG(@" localDocuments:");
    for (NSURL* document in docs) {
    FLOG(@"  %@", [document lastPathComponent]);
    }
    
    
    NSURL *iCloudDirectory = [self iCloudCoreDataURL];
    
    FLOG(@"  iCloudDirectory is %@", iCloudDirectory);
    
    // If iCloud is not available then just return
    if (iCloudDirectory == nil) return;
    
    docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:iCloudDirectory includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"  ICLOUD DOCUMENTS (%d)", [docs count]);
    FLOG(@"  =====================");
    FLOG(@" localDocuments:");
    for (NSURL* document in docs) {
    FLOG(@"  %@", [document lastPathComponent]);
    }
    FLOG(@"   ");
    FLOG(@"   ");
}
/*! Lists all FILES on a device in the apps DATA directory excluding those in the *.app directory and the DOCUMENTS in the iCloud container.
 Note that DOCUMENTS are the user created UIManagedDocuments not all the file system files.
 
 */
- (void)listAllFiles {
    NSURL* dataDirectoryURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dataDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"   ");
    FLOG(@"  ALL LOCAL DOCUMENTS (%d)", [docs count]);
    FLOG(@"  ====================");
    FLOG(@" localDocuments:");
    for (NSURL* document in docs) {
        FLOG(@"  %@", [document lastPathComponent]);
        
        // Ignore the .app folder
        if (![document.lastPathComponent isEqualToString:@"CoreDataLibraryApp.app"])
            [self listAllFilesInDirectory:document padding:@"  "];
    }
    
    // returns the iCloud container /CoreData directory URL whose root directories are the UbiquityNameKeys for all Core Data documents
    NSURL *iCloudDirectory = [[OSCDStackManager sharedManager] iCloudCoreDataURL];
    
    FLOG(@"  iCloudDirectory is %@", iCloudDirectory);
    
    // If iCloud is not available then just return
    if (iCloudDirectory == nil) return;
    
    
    docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:iCloudDirectory includingPropertiesForKeys:nil options:0 error:nil];
    FLOG(@"   ");
    FLOG(@"  ICLOUD DOCUMENTS (%d)", [docs count]);
    FLOG(@"  =====================");
    FLOG(@" localDocuments:");
    for (NSURL* document in docs) {
    FLOG(@"  %@", [document lastPathComponent]);
    }
    FLOG(@"   ");
    FLOG(@"   ");
}
/*! Recursively lists all files
 
 @param dir The directory to list
 @param padding A string padding to indent the output depending on the level of recursion
 */
- (void)listAllFilesInDirectory:(NSURL*)dir padding:(NSString*)padding {
    
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir includingPropertiesForKeys:nil options:0 error:nil];
    
    for (NSURL* document in docs) {
        
        FLOG(@" %@ %@", padding, [document lastPathComponent]);
        
        BOOL isDir;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:document.path isDirectory:&isDir];
        
        if (fileExists && isDir) {
            [self listAllFilesInDirectory:document padding:[NSString stringWithFormat:@"  %@", padding]];
        }
        
    }
}

@end
