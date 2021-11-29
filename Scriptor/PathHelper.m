//
//  PathHelper.m
//  Allora
//
//  Created by Sai Chow on 12/9/11.
//  Copyright (c) 2011 Intouch Solutions, Inc. All rights reserved.
//

#import "PathHelper.h"
#import "FileHelper.h"



NSString *const PATH_USER_BASE = @"users";
NSString *const PATH_USER_TEMP = @"temp";
NSString *const PATH_USER_IMAGES = @"images";
NSString *const PATH_USER_VIDEOS = @"videos";
NSString *const PATH_USER_AUDIO = @"audio";
NSString *const PATH_USER_SCRIPTS = @"scripts";
NSString *const PATH_USER_DOCUMENTS = @"documents";
NSString *const PATH_APP = @"app";


@implementation PathHelper

#pragma mark -
#pragma mark Instance methods


- (NSString*)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath createIfNotExist:(BOOL)createIfNotExist {
    return [PathHelper pathHelper:baseDir appendPath:appendPath createIfNotExist:createIfNotExist];
}

- (NSString*)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath {
    return [PathHelper pathHelper:baseDir appendPath:appendPath];
}


- (NSString *)getPath:(NSSearchPathDirectory)dirType {
    return [PathHelper getPath:dirType];
}

#pragma mark - Static methods


+ (NSString *)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath createIfNotExist:(BOOL)createIfNotExist {
    if (baseDir != nil && appendPath != nil) {
        NSString *path = [baseDir stringByAppendingPathComponent:appendPath];

        if (![FileHelper directoryExists:path]) {
            if (createIfNotExist) {
                [FileHelper createDirectory:path withIntermediateDirectories:YES];
            }
            return path;
        } else {
            return path;
        }
    }
    return nil;
}

+ (NSString *)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath {
    return [self pathHelper:baseDir appendPath:appendPath createIfNotExist:YES];
}

+ (NSString *)getPath:(NSSearchPathDirectory)dirType {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(dirType, NSUserDomainMask, YES);
    NSString *docDir = nil;
    if (paths != nil) {
        docDir = paths[0];
    }
    return docDir;
}


@end
