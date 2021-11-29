//
//  FileHelper.m
//  Allora
//
//  Created by Sai Chow on 12/9/11.
//  Copyright (c) 2011 Intouch Solutions, Inc. All rights reserved.
//
#include <glob.h>
#import "FileHelper.h"
#import "PathHelper.h"

@implementation FileHelper

#pragma mark -
#pragma mark - Instance methods
// todo - refactor out all static methods from client code

- (NSString*)loadContentsOfFile:(NSString*)filePath {
    NSStringEncoding encoding;
    return [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:NULL];
}

- (NSDictionary*)loadPlistDictionaryFromFilePath:(NSString*)filePath {
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

- (BOOL)createEmptyFile:(NSString*)fileName {
    return [FileHelper createEmptyFile:fileName];
}

- (BOOL)fileExists:(NSString*)fileName {
    return [FileHelper fileExists:fileName];
}

- (BOOL)deleteFile:(NSString*)fileName {
    return [FileHelper deleteFile:fileName];
}

- (BOOL)moveFile:(NSString*)srcFileName to:(NSString*)destFileName {
    return [FileHelper moveFile:srcFileName to:destFileName];
}

- (BOOL)moveDirectory:(NSString*)fromDirPath to:(NSString*)toDirPath {
    return [FileHelper moveDirectory:fromDirPath to:toDirPath];
}

- (BOOL)deleteDirectory:(NSString*)directoryPath {
    return [FileHelper deleteDirectory:directoryPath];
}

- (BOOL)directoryExists:(NSString*)directoryName {
    return [FileHelper directoryExists:directoryName];
}

- (void)createDirectory:(NSString*)directoryName {
    return [FileHelper createDirectory:directoryName];
}

- (void)createDirectory:(NSString*)directoryName withIntermediateDirectories:(BOOL)intermediateDirs {
    return [FileHelper createDirectory:directoryName withIntermediateDirectories:intermediateDirs];
}

- (NSArray*)getListOfFilesInDir:(NSString*)dirPath havingFileExtension:(NSString*)fileExt recursiveSearch:(BOOL)isRecursive {
    return [FileHelper getListOfFilesInDir:dirPath havingFileExtension:fileExt recursiveSearch:isRecursive];
}

- (NSArray*)findMatchingFiles:(NSString*)filePattern inDirectory:(NSString*)directory {
    return [FileHelper findMatchingFiles:filePattern inDirectory:directory];
}

- (long)getFileSize:(NSString*)fileName {
    return [FileHelper getFileSize:fileName];
}

- (NSString*)getFileCreationDate:(NSString*)fileName {
    return [FileHelper getFileCreationDate:fileName];
}

- (NSString*)getFileModificationDate:(NSString*)fileName {
    return [FileHelper getFileModificationDate:fileName];
}

- (BOOL)isEnoughSpaceToCopyBaseOnPath:(NSString*)path {
    return [FileHelper isEnoughSpaceToCopyBaseOnPath:path];
}

- (float)getTotalDiskSpaceInBytes {
    return [FileHelper getTotalDiskSpaceInBytes];
}

- (unsigned long long int)folderSize:(NSString *)folderPath {
    return [FileHelper folderSize:folderPath];
}

- (NSArray*)getListOfFileInDir:(NSString*)dirPath {
    return [FileHelper getListOfFileInDir:dirPath];
}

#pragma mark -
#pragma mark Static methods

+ (BOOL)createEmptyFile:(NSString*)fileName {
    if( [FileHelper fileExists:fileName] ) {
        [FileHelper deleteFile:fileName];
    }
    
    return [[NSFileManager defaultManager] createFileAtPath:fileName
                                                   contents:[NSData data]
                                                 attributes:nil];
}

+ (BOOL)fileExists:(NSString*)fileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
}

+ (BOOL)deleteFile:(NSString*)fileName {
    if( [FileHelper fileExists:fileName] ) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        return( ! [FileHelper fileExists:fileName] );
    }
    
    return YES;
}

+ (BOOL)deleteDirectory:(NSString*)directoryPath {
    if ([FileHelper directoryExists:directoryPath]) {
        NSError *error;
        return [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
    }
    
    return YES;
}

+ (BOOL)moveFile:(NSString*)srcFileName to:(NSString*)destFileName {
    BOOL moveResult = NO;
    NSError *error;
    moveResult = [[NSFileManager defaultManager] moveItemAtPath:srcFileName
                                                   toPath:destFileName
                                                    error:&error];
    return moveResult;
}

+ (BOOL)moveDirectory:(NSString*)fromDirPath to:(NSString*)toDirPath {
    BOOL moveResult = NO;
    NSError *err;
    moveResult =[[NSFileManager defaultManager] moveItemAtPath:fromDirPath toPath:toDirPath error:&err];
    return moveResult;
}

+ (BOOL)directoryExists:(NSString*)directoryName {
    return [[NSFileManager defaultManager] fileExistsAtPath:directoryName];
}

+ (void)createDirectory:(NSString*)directoryName {
    [FileHelper createDirectory:directoryName withIntermediateDirectories:NO];
}

+ (void)createDirectory:(NSString*)directoryName withIntermediateDirectories:(BOOL)intermediateDirs {
    NSError *err;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:directoryName
                                             withIntermediateDirectories:intermediateDirs
                                                              attributes:nil
                                                                   error:&err];
    
    if( ! success ) {
        if (![self fileExists:directoryName]) {
        
            @throw [NSException exceptionWithName:@"UnableToCreateDirectoryException"
                                           reason:[NSString stringWithFormat:@"Unable to create directory '%@'", directoryName]
                                         userInfo:nil];
        }
    }
}

+ (NSArray*)getListOfFileInDir:(NSString*)dirPath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* listOfAllFiles = [fileManager contentsOfDirectoryAtPath:dirPath error:NULL];
    return listOfAllFiles;
}

+ (NSArray*)getListOfFilesInDir:(NSString*)dirPath havingFileExtension:(NSString*)fileExt recursiveSearch:(BOOL)isRecursive {
    NSMutableArray* listOfFiles = [[NSMutableArray alloc] init];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray* listOfAllFiles = [fileManager contentsOfDirectoryAtPath:dirPath error:NULL];
    NSString* fullyQualifiedFileName;
    
    for( NSString* dirEntry in listOfAllFiles ) {
        fullyQualifiedFileName = [NSString stringWithFormat:@"%@/%@", dirPath, dirEntry];
        BOOL isDirectory = NO;
        
        [fileManager fileExistsAtPath:fullyQualifiedFileName isDirectory:&isDirectory];
        
        if( ! isDirectory ) {
            if( [dirEntry hasSuffix:fileExt] ) {
                [listOfFiles addObject:fullyQualifiedFileName];
            }
        } else if (![@".." isEqualToString:dirEntry] && ![@"." isEqualToString:dirEntry] && isRecursive) {
            [listOfFiles addObjectsFromArray:[self getListOfFilesInDir:[PathHelper pathHelper:dirPath appendPath:dirEntry] havingFileExtension:fileExt recursiveSearch:isRecursive]];
        }
    }
    
    return listOfFiles;
}

+ (NSArray*)findMatchingFiles:(NSString*)filePattern inDirectory:(NSString*)directory {
    NSMutableArray* listMatchingFiles = [[NSMutableArray alloc] init];
    NSString *fullFilePattern = [directory stringByAppendingString:filePattern];
    const char* pattern = fullFilePattern.UTF8String;
    glob_t gt;
    
    if ( 0 == glob(pattern, 0, NULL, &gt) ) {
        const int numMatchingFiles = gt.gl_matchc;
        
        for( int i = 0; i < numMatchingFiles; ++i ) {
            [listMatchingFiles addObject:@(gt.gl_pathv[i])];
        }
    }
    globfree(&gt);
    
    return listMatchingFiles;
}

+ (long)getFileSize:(NSString*)fileName {
    if( [FileHelper fileExists:fileName] ) {
        NSDictionary* dictAttributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:fileName
                                                         error:NULL];
        
        if( nil != dictAttributes )
        {
            NSNumber * sValue = dictAttributes[NSFileSize];
            return sValue.longValue;
        }
    }
    
    return -1L;
}

+ (NSString*)getFileCreationDate:(NSString*)fileName {
    if( [FileHelper fileExists:fileName] ) {
        NSDictionary* dictAttributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:fileName
                                                         error:NULL];
        
        if( nil != dictAttributes )
        {
            NSDate * dValue = dictAttributes[NSFileCreationDate];
            return dValue.description;
        }
    }
    
    return nil;
}

+ (NSString*)getFileModificationDate:(NSString*)fileName {
    if( [FileHelper fileExists:fileName] ) {
        NSDictionary* dictAttributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:fileName
                                                         error:NULL];
        
        if( nil != dictAttributes ) {
            NSDate * dValue = dictAttributes[NSFileModificationDate];
            return dValue.description;
        }
    }
    
    return nil;
}

+ (BOOL)isEnoughSpaceToCopyBaseOnPath:(NSString *)path {
    return [FileHelper getTotalDiskSpaceInBytes] > [FileHelper folderSize:path];
}

+ (float)getTotalDiskSpaceInBytes {  
    float totalSpace = 0.0f;  
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths.lastObject error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];  
        totalSpace = fileSystemSizeInBytes.floatValue;  
    } else {  
       
    }  
    
    return totalSpace;  
}  

+ (unsigned long long int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

+ (NSURL*)applicationDirectory
{
    NSString* bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSFileManager*fm = [NSFileManager defaultManager];
    NSURL*    dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if (appSupportDir.count > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [appSupportDir[0] URLByAppendingPathComponent:bundleID];
        
        // If the directory does not exist, this method creates it.
        // This method call works in OS X 10.7 and later only.
        NSError*    theError = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                           attributes:nil error:&theError])
        {
            return nil;
        }
    }
    
    return dirPath;
}

@end
