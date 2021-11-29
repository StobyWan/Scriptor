//
//  File.h
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Project *project;

@end
