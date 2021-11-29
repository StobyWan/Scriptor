//
//  Constants.h
//  Scriptor
//
//  Created by Bryan Stober on 1/16/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  SCRIPTOR_YELLOW  [UIColor colorWithRed: 243.0/255.0 green: 183.0/255.0 blue: 25.0/255.0 alpha: 1.0]
#define  SCRIPTOR_LIGHT_YELLOW [UIColor colorWithRed: 0.972 green: 0.831 blue: 0.462 alpha: 1.0]
#define  SCRIPTOR_DARK_GREY  [UIColor colorWithRed: 43.0/255.0 green: 43.0/255.0 blue: 43.0/255.0 alpha: 1.0]
#define  SCRIPTOR_BLACK [UIColor colorWithRed: 0/255.0 green: 0/255.0 blue: 0/255.0 alpha:1.0]
#define  SCRIPTOR_BLUE [UIColor colorWithRed: 0.564 green: 0.968 blue: 0.964 alpha: 1]
#define  SCRIPTOR_LIGHT_LIGHT_YELLOW [UIColor colorWithRed:0.988235 green:0.941177 blue:0.819608 alpha:1]
#define  SCRIPTOR_YELLOW_TEXT [UIColor colorWithRed:222.0/255.0 green:131.0/255.0 blue:20.0/255.0 alpha:1]


@interface Constants : NSObject

extern NSString *const ICLOUD_HTML_FILE_NAME;
extern NSString *const ICLOUD_CSS_FILE_NAME;
extern NSString *const ICLOUD_JS_FILE_NAME;
extern NSString *const LOCAL_HTML_FILE_NAME;
extern NSString *const LOCAL_CSS_FILE_NAME;
extern NSString *const LOCAL_JS_FILE_NAME;
extern NSString* const SCRIPT_TAG;
extern NSString* const HTML_TEMPLATE;
extern NSString* const CSS_TEMPLATE;
extern NSString* const JS_TEMPLATE;
extern NSString * const SETTINGS_USE_ICLOUD_KEY;
extern NSString * const SETTINGS_MAKE_BACKUP_KEY;
extern NSString * const SETTINGS_COLOR_SCHEME_KEY;
extern NSString * const SETTINGS_FTP;
extern NSString * const SETTINGS_FTP_USERNAME;
extern NSString * const SETTINGS_FTP_PASSWORD;
extern NSString * const JSON_FRAMEWORK_URL;
extern NSString * const JSON_FRAMEWORK_FILE_NAME;

@end
