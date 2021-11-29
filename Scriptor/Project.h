//
//  Project.h
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, Framework, Image;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * findTags;
@property (nonatomic, retain) NSString * folderId;
@property (nonatomic, retain) NSNumber * isNewScript;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * scriptTags;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) NSSet *frameworks;
@property (nonatomic, retain) NSSet *images;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addFilesObject:(File *)value;
- (void)removeFilesObject:(File *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

- (void)addFrameworksObject:(Framework *)value;
- (void)removeFrameworksObject:(Framework *)value;
- (void)addFrameworks:(NSSet *)values;
- (void)removeFrameworks:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
