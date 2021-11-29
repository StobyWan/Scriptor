//
//  Constants.m
//  Scriptor
//
//  Created by Bryan Stober on 1/16/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "Constants.h"

NSString *const ICLOUD_HTML_FILE_NAME = @"_UUID_index.html";
NSString *const ICLOUD_CSS_FILE_NAME = @"_UUID_style.css";
NSString *const ICLOUD_JS_FILE_NAME = @"_UUID_script.js";
NSString *const LOCAL_HTML_FILE_NAME = @"index.html";
NSString *const LOCAL_CSS_FILE_NAME = @"style.css";
NSString *const LOCAL_JS_FILE_NAME = @"script.js";
NSString* const SCRIPT_TAG = @"<script src=\"script.js\"></script>\n";
NSString* const CSS_TEMPLATE = @"/* style.css */\n\nbody{\n\n}";
NSString* const JS_TEMPLATE = @"/* script.js */ \n\nfunction test(){\n\n}";
NSString* const HTML_TEMPLATE = @"<!doctype html>\n<html>\n<head>\n<meta charset\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width\" />\n    <title>Title</title>\n<link rel=\"stylesheet\" href=\"style.css\" />\n<script src=\"script.js\"></script>\n</head>\n<body>\n</body>\n</html>";

NSString * const SETTINGS_USE_ICLOUD_KEY  = @"com.bryanstoberdesign.Scriptor.UseiCloudStorage";
NSString * const SETTINGS_MAKE_BACKUP_KEY = @"com.bryanstoberdesign.Scriptor.MakeBackup";
NSString * const SETTINGS_COLOR_SCHEME_KEY = @"com.bryanstoberdesign.Scriptor.ColorScheme";
NSString * const SETTINGS_FTP = @"com.bryanstoberdesign.Scriptor.ftp";
NSString * const SETTINGS_FTP_USERNAME = @"com.bryanstoberdesign.Scriptor.username";
NSString * const SETTINGS_FTP_PASSWORD = @"com.bryanstoberdesign.Scriptor.password";
NSString * const JSON_FRAMEWORK_URL = @"http://scriptor.mobi/frameworks/?appData=1";
NSString * const JSON_FRAMEWORK_FILE_NAME = @"cloud_cdn.json";
@implementation Constants



@end
