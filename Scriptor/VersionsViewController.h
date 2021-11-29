//
//  ScriptPopoverViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptPopoverViewControllerDelegate.h"

@class Framework;

@interface VersionsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) id <ScriptPopoverViewControllerDelegate>delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFramework:(Framework *)framework andDelegate:(UIViewController *)delegate NS_DESIGNATED_INITIALIZER;

@end
