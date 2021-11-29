//
//  DetailViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "WebViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "AddImageViewController.h"


#define FrameworksViewControllerWasCreatedNotification @"FrameworksViewControllerWasCreatedNotification"

@class Project;
@class FrameworksViewController;
@class File;

enum ViewType : NSUInteger {
    ViewTypeHTML = 0,
    ViewTypeCSS = 1,
    ViewTypeJS = 2
};

@interface DetailViewController : GAITrackedViewController <UISplitViewControllerDelegate,MasterViewControllerDelegate,UITextViewDelegate,UIPopoverControllerDelegate,AddImageViewControllerDelegate>

@property (strong, nonatomic) Project *project;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedOutlet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchWebView;
@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) FrameworksViewController *frameworksViewController;
@property (strong, nonatomic) NSNumber *ViewType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userInteractionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) File *file;
@property (strong, nonatomic) UIPopoverController *popoverControl;
@property (weak, nonatomic) id<DetailViewControllerDelegate>delegate;

- (void)configureView;
- (IBAction)segmentToggle:(UISegmentedControl *)sender;
- (IBAction)exportPackageServerFolder:(UIBarButtonItem *)sender;
- (IBAction)buttonPressed:(id)sender;

@end
