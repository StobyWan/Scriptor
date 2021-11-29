//
//  FrameworksViewControllerDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FrameworksViewController;
@class Project;

@protocol FrameworksViewControllerDelegate <NSObject>

- (void)didSelectNewFrameworksInProject:(Project *)project withView:(FrameworksViewController *)view;

@end
