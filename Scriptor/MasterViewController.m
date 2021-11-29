//
//  MasterViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
//    UIDevice *myDevice = [UIDevice currentDevice];
//    NSString *deviceName = myDevice.name;
//    NSString *deviceSystemName = myDevice.systemName;
//    NSString *deviceOSVersion = myDevice.systemVersion;
//    NSString *deviceModel = myDevice.model;

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "FrameworksViewController.h"
#import "JSONLoader.h"
#import "Project.h"
#import "File.h"
#import "Framework.h"
#import "Version.h"
#import "FrameworkJSON.h"
#import "CustomAccessoryView.h"
#import "OSCDStackManager.h"
#import "Constants.h"
#import "ProjectInfoViewController.h"
#import "NSDate+Utilities.h"
#import "FileHelper.h"
#import "NetworkStatusHelper.h"
#import "ProjectTableViewCell.h"

#define ACCESSORY_WIDTH 13.f
#define ACCESSORY_HEIGHT 18.f

@interface MasterViewController (){
    NSArray *_frameworks;
}

@property (strong, nonatomic) NSNumber *selectedIndex;
@property (strong, nonatomic)  NSURL *currentBaseURL;
@property (strong, nonatomic)  NSString *currentFilePath;
@property (strong, nonatomic)  NSURL *currentFileURL;

- (UITableViewCell*)configureCell:(ProjectTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController

#pragma mark - View LifeCycle

- (void)awakeFromNib {
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);

    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super  viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    NSIndexPath *path = (self.tableView).indexPathForSelectedRow;
    if(self.fetchedResultsController.fetchedObjects.count == 0){
        self.addFrameWorksBtn.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else{
        if (self.selectedIndex) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            Project *project = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0]];
            self.addFrameWorksBtn.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.detailViewController.project = project;
            self.detailViewController.delegate = self;
        }
        else{
            if (!path){
                self.selectedIndex = 0;
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                Project *project = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0]];
                self.addFrameWorksBtn.enabled = YES;
                self.navigationItem.leftBarButtonItem.enabled = YES;
                self.detailViewController.project = project;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    
    self.selectedIndex = 0;
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self.editButtonItem setTintColor:SCRIPTOR_DARK_GREY];
    [[UIBarButtonItem appearance] setTintColor:SCRIPTOR_DARK_GREY];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    [addButton setTintColor:SCRIPTOR_DARK_GREY];
    if(self.editing){
        addButton.enabled = NO;
    }
    else{
        addButton.enabled = YES;
    }
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)(self.splitViewController.viewControllers).lastObject;
    self.detailViewController.masterViewController = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged) name:OSStoreChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:OSDataUpdatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification object:nil];
}

- (void)storeChanged {
#ifdef DEBUG
    NSLog(@"storeChanged called");
#endif
    _fetchedResultsController = nil;
    self.managedObjectContext = [OSCDStackManager sharedManager].managedObjectContext;
    self.detailViewController.project = nil;
    NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
    [self.tableView reloadData];
    if (indexPath) {
        self.selectedIndex = @(indexPath.row);
        Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.detailViewController.project = project;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)refreshUI {
    FLOG(@"refreshUI called");
    NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
    [self.tableView reloadData];
    [self.detailViewController configureView];
    if (indexPath) {
        self.selectedIndex = @(indexPath.row);
        Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.detailViewController.project = project;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
}

#pragma mark - Insert New Server Item with Date and Name



- (void)insertNewObject:(id)sender {
    
    self.addFrameWorksBtn.enabled = YES;
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
  
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add New Project" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *text = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
        
        [self performSelector:@selector(loadFrameworksJSONIntoNewProject:) withObject:text afterDelay:.4];
    }]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter text:";
        textField.secureTextEntry = YES;
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)loadFrameworksJSONIntoNewProject:(NSString *)text {
    
    JSONLoader *jsonLoader = [[JSONLoader alloc] init];
    
    if (![self updateJSONFile]) {
        self.currentFileURL = [[NSBundle mainBundle] URLForResource:@"cdn" withExtension:@"json"];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _frameworks = [jsonLoader locationsFromJSONFile:self.currentFileURL];
        [self performSelectorOnMainThread:@selector(createNewProject:) withObject:text waitUntilDone:YES];
    });
}

- (BOOL)updateJSONFile {
    
    if ([[NetworkStatusHelper sharedNetworkStatusHelper] haveConnection]) {
        _currentBaseURL = [FileHelper applicationDirectory];
        _currentFileURL = [self.currentBaseURL URLByAppendingPathComponent:JSON_FRAMEWORK_FILE_NAME];
        _currentFilePath = (self.currentFileURL).relativePath;
        
        BOOL cdnsJSONFileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.currentFilePath];
        
        if (cdnsJSONFileExists) {
            NSDate *modifiedDate = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentFilePath]) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentFilePath error:nil];
                modifiedDate = attributes[NSFileModificationDate];
            }
            
            if ( 5 < [modifiedDate minutesBeforeDate:[NSDate date]]) {
                NSData *cdnsJSON = [NSData dataWithContentsOfURL:[NSURL URLWithString:JSON_FRAMEWORK_URL]];
                [cdnsJSON writeToFile:self.currentFilePath atomically:YES];
#ifdef DEBUG
                NSLog(@"Updated JSON from server %@ more than 5 minutes old",modifiedDate);
#endif
            }
            return cdnsJSONFileExists;
            
        }
        else{
            NSData *cdnsJSON = [NSData dataWithContentsOfURL:[NSURL URLWithString:JSON_FRAMEWORK_URL]];
            [cdnsJSON writeToFile:self.currentFilePath atomically:YES];
#ifdef DEBUG
            NSLog(@"Updated JSON from server");
#endif
            return [[NSFileManager defaultManager] fileExistsAtPath:self.currentFilePath];
        }
        
    }
    else{
        return NO;
    }
}

- (NSString*)URLEncodeString:(NSString *)str {
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)createNewProject:(NSString *)title {
    
    NSManagedObjectContext *context = (self.fetchedResultsController).managedObjectContext;
    NSEntityDescription *entity = (self.fetchedResultsController).fetchRequest.entity;
    Project *project = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:context];
    project.timeStamp = [NSDate date];
    project.lastModified = [NSDate date];
    project.findTags = SCRIPT_TAG;
    project.scriptTags = SCRIPT_TAG;
    project.isNewScript = @0;
    int timestamp = (project.timeStamp).timeIntervalSince1970;
    NSString *folder = [NSString stringWithFormat:@"%d",timestamp];
    project.name = title;
    project.folderId = folder;
    NSArray *arrayOfFiles = @[@{@"fileName" : LOCAL_HTML_FILE_NAME,@"template" : HTML_TEMPLATE, @"type" : @0},
                              @{@"fileName" : LOCAL_CSS_FILE_NAME,@"template" : CSS_TEMPLATE,@"type": @1},
                              @{@"fileName": LOCAL_JS_FILE_NAME,@"template" : JS_TEMPLATE,@"type" : @2}];
    
    for (NSDictionary *fileDict in arrayOfFiles) {
        entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:self.managedObjectContext];
        File *file = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.managedObjectContext];
        file.name = fileDict[@"fileName"];
        file.data = fileDict[@"template"];
        file.type = fileDict[@"type"];
        file.timestamp = project.timeStamp;
        [project addFilesObject:file];
    }
    
    for (FrameworkJSON * frameworkJSON  in _frameworks) {
        frameworkJSON.timeStamp = project.timeStamp;
        entity = [NSEntityDescription entityForName:@"Framework" inManagedObjectContext:self.managedObjectContext];
        Framework *framework = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.managedObjectContext];
        framework.name = frameworkJSON.name;
        framework.site = frameworkJSON.site;
        framework.timeStamp = frameworkJSON.timeStamp;
        framework.snippet = frameworkJSON.snippet;
        framework.imageName = frameworkJSON.imageName;
        framework.heirarchy = frameworkJSON.heirarchy;
        framework.activeVersion = frameworkJSON.activeVersion;
        framework.isActive = [NSNumber numberWithBool:0];
        entity = [NSEntityDescription entityForName:@"Version" inManagedObjectContext:self.managedObjectContext];
        for (NSString *v in frameworkJSON.versions) {
            Version *version = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.managedObjectContext];
            version.number = v;
            [framework addVersionsObject:version];
        }
        [project addFrameworksObject:framework];
    }
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
        [errorAlert show];
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
#endif
    }
    self.selectedIndex = 0;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.detailViewController.project = project;
    [self setEditing:NO];
}

- (void)saveObject {
    UITableViewCell *textFieldRowCell = (UITableViewCell *) self.currentTextfield.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:textFieldRowCell];
    Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
    project.name = self.currentTextfield.text;
    self.currentTextfield = nil;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
        [errorAlert show];
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
#endif
    }
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.fetchedResultsController).sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell = (ProjectTableViewCell*) [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = (self.fetchedResultsController).managedObjectContext;
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        self.currentTextfield = nil;
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
    if (self.fetchedResultsController.fetchedObjects.count  == 0) {
        self.addFrameWorksBtn.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.selectedIndex = 0;
        [self.delegate masterViewControllerReportsNoObjects:self];
    }
    else{
        int value = (self.selectedIndex).intValue;
        if (value > 1) {
            self.selectedIndex = @(value - 1);
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndex = @(indexPath.row);
    Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.detailViewController.project = project;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if(editing == YES)
    {
        self.addFrameWorksBtn.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }
    else {
        
        if ((self.fetchedResultsController.fetchedObjects).count > 0) {
            
            
            Project *project = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0]];
            if (project) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.selectedIndex).integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                
                self.detailViewController.project = project;
            }
            self.addFrameWorksBtn.enabled = YES;
            
            
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = project.name;
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:SCRIPTOR_LIGHT_YELLOW];
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.accessoryView = [[CustomAccessoryView alloc] initWithFrame:CGRectMake(cell.frame.size.width - ACCESSORY_WIDTH, cell.frame.size.height/2 - ACCESSORY_HEIGHT/2, ACCESSORY_WIDTH, ACCESSORY_HEIGHT)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(popLongPressFTPView:)];
    [cell addGestureRecognizer:longPress];
    return cell;
}

- (void)popLongPressFTPView:(UILongPressGestureRecognizer*)sender {
    if (IS_IPAD) {
        if (self.popoverControl.isPopoverVisible) {
            [self.popoverControl dismissPopoverAnimated:NO];
        }
        ProjectInfoViewController *ftpPopoverViewController = [[ProjectInfoViewController alloc] initWithNibName:@"FTPPopoverViewController" bundle:nil];
        CGPoint p = [sender locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        ftpPopoverViewController.project = (Project*)(self.fetchedResultsController.fetchedObjects)[indexPath.row];
        self.popoverControl =[[UIPopoverController alloc] initWithContentViewController:ftpPopoverViewController];
//        self.popoverControl.popoverContentSize = CGSizeMake(300, 132);
        [self.popoverControl presentPopoverFromRect:sender.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
        [errorAlert show];
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
#endif
	}
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ProjectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

#pragma mark - UITextViewDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.currentTextfield = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField; {
    self.currentTextfield = textField;
    [self saveObject];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.currentTextfield = textField;
    [self saveObject];
    [textField resignFirstResponder];

    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.currentTextfield resignFirstResponder];
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"FRAMEWORKSSEGUE"]) {
        NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
        self.selectedIndex = @(indexPath.row);
        Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
        FrameworksViewController *frameworksViewController = segue.destinationViewController;
        frameworksViewController.project = project;
    }
    else if([segue.identifier isEqualToString:@"iphoneDetailSegue"]){
        NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
        self.selectedIndex = @(indexPath.row);
        Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DetailViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.project = project;
    }
}

- (void)detailViewControllerDidAddImageToProject:(DetailViewController *)view{
    [self.tableView reloadData];
}

#pragma mark - Responding to keyboard events

- (void) keyboardWillShow: (NSNotification*) aNotification
{
    NSDictionary* info = aNotification.userInfo;
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.currentTextfield.frame.origin) ) {
        [self.tableView scrollRectToVisible:self.currentTextfield.frame animated:YES];
    }
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification
{
   
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (NSTimeInterval) keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = notification.userInfo;
    NSValue* value = info[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue: &duration];
    
    return duration;
}
@end

