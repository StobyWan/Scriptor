//
//  MasterViewControllerDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/5/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MasterViewController;
@class Project;

@protocol MasterViewControllerDelegate <NSObject>

- (void)masterViewControllerReportsNoObjects:(MasterViewController *)view;

@end
