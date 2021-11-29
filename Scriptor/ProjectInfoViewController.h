//
//  FTPPopoverViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/23/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Project;

typedef NS_ENUM(NSInteger, ProjectInfoItems) {
    ProjectInfoName,
    ProjectInfoModifiedDate,
    ProjectInfoCreatedDate,
    ProjectInfoItemsCount
};

typedef NS_ENUM(NSInteger, TableViewSections) {
    TableViewSectionsProjectInfo,
    TableViewSectionsProjectImages,
    TableViewSectionsCount
};

@interface ProjectInfoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) Project *project;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)setEditingAction:(UIBarButtonItem *)sender;
@end
