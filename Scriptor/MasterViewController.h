//
//  MasterViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MasterViewControllerDelegate.h"
#import "DetailViewControllerDelegate.h"

enum FileType : NSUInteger {
        FileTypeHTML = 0,
        FileTypeCSS = 1,
        FIleTypeJS = 2,
};

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,UITextFieldDelegate,DetailViewControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UITableViewCell *currentCell;
@property (strong, nonatomic) UITextField * currentTextfield;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <MasterViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFrameWorksBtn;
@property (strong, nonatomic) UIPopoverController *popoverControl;

@end
