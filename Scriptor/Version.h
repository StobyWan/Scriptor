//
//  Version.h
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Framework;

@interface Version : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) Framework *framework;

@end
