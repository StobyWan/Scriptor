//
//  FTPPopoverViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/23/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "ProjectInfoViewController.h"
#import "Project.h"
#import "Image.h"

static const float ITEM_DEFAULT_MAX_HEIGHT = 300.0f;
static const int POPOVER_WIDTH = 300;
//static const int POPOVER_MAX_HEIGHT = 400;
static const int POPOVER_MIN_HEIGHT = 132;
static const float ktableRowHeight = 44.0f;

@interface ProjectInfoViewController ()

@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation ProjectInfoViewController

- (void)setProject:(id)project {
    if (_project != project) {
        _project = project;
        
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _images = [self loadImages];
    [self forcePopoverSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.project = nil;
    self.images = nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case TableViewSectionsProjectInfo:
            return @"Project Info";
            break;
        case TableViewSectionsProjectImages:
            return @"Project Images";
            break;
        default:
             return @"";
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableViewSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TableViewSectionsProjectInfo:
            return ProjectInfoItemsCount;
            break;
        case TableViewSectionsProjectImages:
            if (self.images.count == 0) {
                return 1;
            }
            else{
                return self.images.count;
            }
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == TableViewSectionsProjectInfo) {
        
        if(indexPath.row == ProjectInfoName) {
            if (self.project.name.length == 0) {
                cell.textLabel.text =NSLocalizedString(@"ftppopover_untitled", @"Untitled");
            }
            else{
                cell.textLabel.text = self.project.name;
            }
        }
        else if(indexPath.row == ProjectInfoModifiedDate){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            NSDate *date = self.project.lastModified;
            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            cell.textLabel.text = [NSString stringWithFormat:@"Last Modified: %@", formattedDateString];
        }
        else if(indexPath.row == ProjectInfoCreatedDate){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            NSDate *date = self.project.timeStamp;
            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            cell.textLabel.text = [NSString stringWithFormat:@"Date Created: %@", formattedDateString];
        }
        UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 15.0 ];
        cell.textLabel.font = myFont;
    }
    
    if (indexPath.section == TableViewSectionsProjectImages) {
        if (self.images.count > 0) {
            Image *image =(self.images)[indexPath.row];
            cell.textLabel.text = image.imageName;
        }
        else{
             cell.textLabel.text = @"No Imported Images";
        }
       
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == TableViewSectionsProjectInfo) {
        
    }
    if (indexPath.section == TableViewSectionsProjectImages) {
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == TableViewSectionsProjectInfo) {
        return NO;
    }
    else{
        if (self.images.count == 0) {
            return NO;
        }
        else {
            return YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = self.project.managedObjectContext;
        Image *image = (self.images)[indexPath.row];
        [self.project removeImagesObject:image];
        [self.images removeObjectAtIndex:indexPath.row];
        NSError *error = nil;
        if (![context save:&error]) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
            [errorAlert show];
#ifdef DEBUG
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
#endif
        }
    }
    [self.tableView reloadData];
    [self forcePopoverSize];
}


- (NSMutableArray*)loadImages {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray * images = [NSArray arrayWithArray:[self.project.images sortedArrayUsingDescriptors:sortDescriptors]];
    NSMutableArray *ma = [NSMutableArray arrayWithArray:images];
    return ma;
}

- (void)forcePopoverSize {
    self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, [self heightForTableWithinPopoverWithMaxiumumHeight:ITEM_DEFAULT_MAX_HEIGHT]);;
}

- (float)rowHeight {
    return ktableRowHeight;
}

- (float)heightForTableWithinPopoverWithMaxiumumHeight:(float)maxHeight {
    
    float heightSection1 = (float)([self rowHeight] * [self tableView:self.tableView numberOfRowsInSection:TableViewSectionsProjectInfo]);
    float heightSection2 = (float)([self rowHeight] * [self tableView:self.tableView numberOfRowsInSection:TableViewSectionsProjectImages]);
    
    float height = heightSection1 + heightSection2 + 96.0f;
    if (height > maxHeight) {
        height = maxHeight;
        self.tableView.scrollEnabled= YES;
    }
    else if (height < POPOVER_MIN_HEIGHT) {
        
        height = POPOVER_MIN_HEIGHT;
    }
    
    return  height;
}
- (IBAction)setEditingAction:(UIBarButtonItem *)sender {
    if (self.tableView.isEditing) {
        self.editButton.title = @"Edit";
        [self.tableView setEditing:NO];
    }else{
        self.editButton.title = @"Done";
          [self.tableView setEditing:YES];
    }
  
}
@end
