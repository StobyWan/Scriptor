//
//  CDN.h
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameworkJSON : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@property (strong,nonatomic) NSDate *timeStamp;
@property (readonly) NSString *name;
@property (readonly) NSString *snippet;
@property (readonly) NSString *site;
@property (readonly) NSString *imageName;
@property (readonly) NSArray *versions;
@property (readonly) NSNumber *heirarchy;
@property (strong, nonatomic) NSString *activeVersion;
@property (assign) BOOL isActive;

@end
