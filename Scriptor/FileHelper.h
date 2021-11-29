//
//  FileHelper.h
//  Allora
//
//  Created by Sai Chow on 12/9/11.
//  Copyright (c) 2011 Intouch Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

// swap these out for instance mthods
#pragma mark -
#pragma mark Instance methods

- (NSString*)loadContentsOfFile:(NSString*)filePath;
- (NSDictionary*)loadPlistDictionaryFromFilePath:(NSString*)filePath;
- (BOOL)createEmptyFile:(NSString*)fileName;
- (BOOL)fileExists:(NSString*)fileName;
- (BOOL)deleteFile:(NSString*)fileName;
- (BOOL)moveFile:(NSString*)srcFileName to:(NSString*)destFileName;
- (BOOL)moveDirectory:(NSString*)fromDirPath to:(NSString*)toDirPath;
- (BOOL)deleteDirectory:(NSString*)directoryPath;
- (BOOL)directoryExists:(NSString*)directoryName;
- (void)createDirectory:(NSString*)directoryName;
- (void)createDirectory:(NSString*)directoryName withIntermediateDirectories:(BOOL)intermediateDirs;
- (NSArray*)getListOfFilesInDir:(NSString*)dirPath havingFileExtension:(NSString*)fileExt recursiveSearch:(BOOL)isRecursive;
- (NSArray*)findMatchingFiles:(NSString*)filePattern inDirectory:(NSString*)directory;
- (long)getFileSize:(NSString*)fileName;
- (NSString*)getFileCreationDate:(NSString*)fileName;
- (NSString*)getFileModificationDate:(NSString*)fileName;
- (BOOL)isEnoughSpaceToCopyBaseOnPath:(NSString*)path;
@property (NS_NONATOMIC_IOSONLY, getter=getTotalDiskSpaceInBytes, readonly) float totalDiskSpaceInBytes;
- (unsigned long long int)folderSize:(NSString*)folderPath;
- (NSArray*)getListOfFileInDir:(NSString*)dirPath;

#pragma mark -
#pragma mark Class methods

+ (BOOL)createEmptyFile:(NSString*)fileName;
+ (BOOL)fileExists:(NSString*)fileName;
+ (BOOL)deleteFile:(NSString*)fileName;
+ (BOOL)moveFile:(NSString*)srcFileName to:(NSString*)destFileName;
+ (BOOL)moveDirectory:(NSString*)fromDirPath to:(NSString*)toDirPath;
+ (BOOL)deleteDirectory:(NSString*)directoryPath;
+ (BOOL)directoryExists:(NSString*)directoryName;
+ (void)createDirectory:(NSString*)directoryName;
+ (void)createDirectory:(NSString*)directoryName withIntermediateDirectories:(BOOL)intermediateDirs;
+ (NSArray*)getListOfFilesInDir:(NSString*)dirPath havingFileExtension:(NSString*)fileExt recursiveSearch:(BOOL)isRecursive;
+ (NSArray*)findMatchingFiles:(NSString*)filePattern inDirectory:(NSString*)directory;
+ (long)getFileSize:(NSString*)fileName;
+ (NSString*)getFileCreationDate:(NSString*)fileName;
+ (NSString*)getFileModificationDate:(NSString*)fileName;
+ (BOOL)isEnoughSpaceToCopyBaseOnPath:(NSString *)path;
+ (float)getTotalDiskSpaceInBytes;
+ (unsigned long long int)folderSize:(NSString *)folderPath;
+ (NSArray*)getListOfFileInDir:(NSString*)dirPath;
+ (NSURL*)applicationDirectory;
@end
