//
//  PathHelper.h
//  Allora
//
//  Created by Sai Chow on 12/9/11.
//  Copyright (c) 2011 Intouch Solutions, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathHelper : NSObject


extern NSString *const PATH_USER_BASE;
extern NSString *const PATH_USER_TEMP;

extern NSString *const PATH_USER_IMAGES;
extern NSString *const PATH_USER_VIDEOS;
extern NSString *const PATH_USER_AUDIO;
extern NSString *const PATH_USER_SCRIPTS;
extern NSString *const PATH_USER_DOCUMENTS;
extern NSString *const PATH_USER_PRESENTATION_STYLES;
extern NSString *const PATH_APP;


#pragma mark -
#pragma mark - Static methods
+ (NSString *)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath;

+ (NSString *)getPath:(NSSearchPathDirectory)dirType;
+ (NSString *)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath createIfNotExist:(BOOL)createIfNotExist;
#pragma mark -
#pragma mark Instance methods

// added instance methods to help with testing, these should eventually replace the static methods

- (NSString*)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath;
- (NSString*)pathHelper:(NSString *)baseDir appendPath:(NSString *)appendPath createIfNotExist:(BOOL)createIfNotExist;
- (NSString *)getPath:(NSSearchPathDirectory)dirType;
@end
