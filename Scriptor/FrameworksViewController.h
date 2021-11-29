//
//  SettingsViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/5/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameworksViewControllerDelegate.h"
#import "GAITrackedViewController.h"
#import "Project.h"
#import "ScriptPopoverViewControllerDelegate.h"

@interface FrameworksViewController : GAITrackedViewController <UICollectionViewDataSource, UICollectionViewDelegate,UIPopoverControllerDelegate,ScriptPopoverViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Project *project;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIPopoverController *popoverControl;
@property (copy, nonatomic) NSString *finalString;
@property (strong, nonatomic) NSArray *frameworks;
@property (weak, nonatomic) id <FrameworksViewControllerDelegate>delegate;

- (IBAction)doneButton:(UIBarButtonItem *)sender;


@end
