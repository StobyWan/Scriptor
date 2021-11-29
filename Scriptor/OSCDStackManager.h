//
//  OSDocumentManager.h
//  Common
//
//  Created by Duncan Groenewald on 15/07/13.
//  Copyright (c) 2013 Duncan Groenewald. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Macros.h"
//#import "OSManagedDocument.h"
//#import "Utilities.h"
#define FLOG(format, ...)               NSLog(@"%@.%@", [self class], [NSString stringWithFormat:format, ##__VA_ARGS__])

@interface FileRepresentation : NSObject

@property (nonatomic, readonly) NSString* fileName;
@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, retain) NSURL* previewURL;
@property (nonatomic, readonly) NSString* fileDate;
@property (nonatomic, readonly) NSNumber* percentDownloaded;
@property (retain) NSNumber* isDownloaded;
@property  bool ready;

- (instancetype)initWithFileName:(NSString*)fileName url:(NSURL*)url NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFileName:(NSString*)fileName url:(NSURL*)url date:(NSString*)fileDate NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFileName:(NSString*)fileName url:(NSURL*)url percentDownloaded:(NSNumber*)percent NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *modifiedDate;

@end

// CloudManager performs file management asynchronously so we need callbacks to let the requester know when we are done
@protocol OSFileManagerProtocol <NSObject>
@required
-(void)fileHasBeenOpened:(NSURL*)file;
-(void)fileHasBeenCreated:(NSURL*)file;
-(void)fileHasBeenDeleted:(NSURL*)file;
-(void)fileHasBeenClosed:(NSURL*)file;
@end

@interface OSCDStackManager : NSObject {
    
    BOOL _useICloudStorage;

    NSArray * _localURLs;
    NSArray * _iCloudURLs;
    NSArray* _localDocuments;

    BOOL _isBusy;
    BOOL _isMigratingToICloud;
    BOOL _isMigratingToLocal;
    NSURL *_migratingFileURL;
    
    bool _deletingDocument;
    bool _creatingDocument;
    bool _creatingNewFile;

    int _migrationCounter;
    
    bool _clearFiles;  // set this to delete all files on the device on startup
    
    bool _storesChanging;
    
    UIAlertView* _storesUpdatingAlert;
    UIAlertView* _cloudChoiceAlert;
    UIAlertView* _cloudChangedAlert;
    UIAlertView* _migratingAlert;
    UIAlertView* _cloudMergeChoiceAlert;

    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSURL *_storeURL;

    NSMetadataQuery* _query;

}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSURL *persistentStoreName;
@property (strong, nonatomic) NSURL *storeURL;

- (void)saveContext;
- (void)setVersion;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;
- (NSArray *)getData:(NSString*)entityName sortField:(NSString*)sortKey predicate:(NSPredicate*)predicate;

@property (readwrite, retain)   NSTimer *iCloudUpdateTimer;

@property (nonatomic)           BOOL isCloudEnabled;
@property (nonatomic)           BOOL deleteICloudFiles;
@property (nonatomic, readonly) NSURL* dataDirectoryURL;
@property (nonatomic, readonly) NSURL* documentsDirectoryURL;
@property (nonatomic)           NSString* ubiquityID;
@property (nonatomic, strong)   NSString *cloudPreferenceKey;
@property (nonatomic, strong)   NSString *cloudPreferenceSet;
@property (nonatomic, strong)   NSString *makeBackupPreferenceKey;
@property (nonatomic, strong)   NSString *ubiquityContainerKey;
@property (nonatomic, strong)   NSString *ubiquityIDToken;


+ (OSCDStackManager*)sharedManager;
- (void)setUbiquityID:(NSString*)ubiquityID;
- (void)checkUserICloudPreferenceAndSetupIfNecessary;
- (void)performApplicationWillEnterForegroundCheck;
@property (NS_NONATOMIC_IOSONLY, readonly) bool backupCurrentStore;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *iCloudCoreDataURL;
@property (NS_NONATOMIC_IOSONLY, readonly) bool canUseICloud;
@property (NS_NONATOMIC_IOSONLY, getter=isICloudAvailable, readonly) bool ICloudAvailable;
@property (NS_NONATOMIC_IOSONLY, getter=isBusy, readonly) bool busy;

- (void)saveDocument;
- (void)closeDocument;
- (void)postUIUpdateNotification;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *icloudStoreOptions;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *localStoreOptions;
@property (NS_NONATOMIC_IOSONLY, readonly) bool moveStoreToLocal;
@property (NS_NONATOMIC_IOSONLY, readonly) bool moveStoreToICloud;

@end

NSString* const ICloudStateUpdatedNotification;

NSString* const OSFileDeletedNotification;
NSString* const OSFileCreatedNotification;
NSString* const OSFileClosedNotification;
NSString* const OSFilesUpdatedNotification;
NSString* const OSDataUpdatedNotification;
NSString* const OSStoreChangeNotification;
