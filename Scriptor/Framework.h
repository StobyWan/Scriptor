//
//  Framework.h
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, Version;

@interface Framework : NSManagedObject

@property (nonatomic, retain) NSString * activeVersion;
@property (nonatomic, retain) NSNumber * heirarchy;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * snippet;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) NSSet *versions;
@end

@interface Framework (CoreDataGeneratedAccessors)

- (void)addVersionsObject:(Version *)value;
- (void)removeVersionsObject:(Version *)value;
- (void)addVersions:(NSSet *)values;
- (void)removeVersions:(NSSet *)values;

@end
