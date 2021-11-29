//
//  SettingsViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/5/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "FrameworksViewController.h"
#import "Cell.h"
#import "JSONLoader.h"
#import "FrameworkJSON.h"
#import "VersionsViewController.h"
#import "Framework.h"
#import "Version.h"

#define FrameworksViewControllerWasCreatedNotification @"FrameworksViewControllerWasCreatedNotification"

NSString *kCellID = @"cellID";

@interface FrameworksViewController ()
    
@property (strong, nonatomic) NSMutableArray *currentSelectedFrameworks;
@property (strong, nonatomic) NSMutableArray *pastSelectedFrameworks;
@property (strong,nonatomic) NSIndexPath *currentlySelectedIndexPath;
    
@end

@implementation FrameworksViewController
    
- (void)setProject:(id)project {
    if (_project != project) {
        _project = project;
    }
}
    
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _currentSelectedFrameworks = [[NSMutableArray alloc] init];
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    [self setUpInitialArray];
    NSString *title = self.project.name;
    if (title == nil) {
        title = @"Untiled";
    }
    NSString *message = [NSString stringWithFormat:@"Select frameworks to add to the %@ project", title];
    self.titleItem.title = message;
}
    
- (void)setUpInitialArray {
    
    int i = 0;
    self.project.findTags = self.project.scriptTags;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"heirarchy" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    self.frameworks = [NSArray arrayWithArray:[self.project.frameworks sortedArrayUsingDescriptors:sortDescriptors]];
    for (Framework *framework in self.frameworks) {
        if ([framework.isActive  isEqual: @1]) {
            [self.currentSelectedFrameworks addObject:framework];
            NSIndexPath *selection = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:selection animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        i++;
    }
}
    
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
    
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName = @"Frameworks View";
}
    
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}
    
- (IBAction)doneButton:(UIBarButtonItem *)sender {
    [self exitView];
}
    
- (void)exitView {
    
    NSString *startString = @"";
    NSString *script = @"";
    for (Framework *framework in self.frameworks) {
        if ([framework.isActive  isEqual:@1] ) {
            NSString *snippet = framework.snippet;
            NSArray *components = [snippet componentsSeparatedByString:@"/"];
            NSMutableArray *arrayOfURL = [NSMutableArray arrayWithArray:components];
            arrayOfURL[6] = framework.activeVersion;
            NSString *urlString = [arrayOfURL componentsJoinedByString:@"/"];
            framework.snippet = urlString;
            script = [[NSString stringWithFormat:@"<script src=\"%@\"></script>\n",framework.snippet] copy];
            startString = [[startString stringByAppendingString:script] copy];
        }
    }
    self.finalString = [[startString  stringByAppendingString:@"<script src=\"script.js\"></script>\n"] copy];
    self.project.scriptTags = self.finalString;
    self.project.isNewScript = @1;
#ifdef DEBUG
    NSLog(@" FINAL STRING %@",self.project.scriptTags);
#endif
    NSManagedObjectContext *context = self.project.managedObjectContext;
    NSError *error = nil;
    if (![context save:&error]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
        [errorAlert show];
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
#endif
    }
    else{
#ifdef DEBUG
        NSLog(@"Saved On Done!");
#endif
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FrameworksViewControllerWasCreatedNotification
                                                        object:self.project];
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.frameworks.count;
}
    
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    Framework *framework = (self.frameworks)[indexPath.item];
    NSString *nameAndVersion = [NSString stringWithFormat:@"%@ %@",framework.name,framework.activeVersion];
    cell.label.text = nameAndVersion;
    cell.image.image = [UIImage imageNamed:framework.imageName];
    UILongPressGestureRecognizer *gestureReconizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:gestureReconizer];
    
    return cell;
}
    
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Framework *framework = (self.frameworks)[indexPath.item];
    if (framework.isActive == [NSNumber numberWithBool:1]) {
        return NO;
    }
    else{
        return YES;
    }
}
    
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Framework *framework = (self.frameworks)[indexPath.item];
    framework.isActive = [NSNumber numberWithBool:1];
}
    
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    Framework *framework = (self.frameworks)[indexPath.item];
    framework.isActive = [NSNumber numberWithBool:0];
}
    
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (IS_IPAD) {
    if (self.popoverControl.isPopoverVisible) {
        [self.popoverControl dismissPopoverAnimated:YES];
    }
    self.currentlySelectedIndexPath = [self.collectionView indexPathForItemAtPoint:sender.view.frame.origin];
    Framework *framework = (self.frameworks)[self.currentlySelectedIndexPath.item];
    VersionsViewController *versionsViewController = [[VersionsViewController alloc] initWithNibName:@"ScriptPopoverViewController" bundle:nil withFramework:framework andDelegate:self];
    self.popoverControl = [[UIPopoverController alloc] initWithContentViewController:versionsViewController];
    self.popoverControl.delegate = self;
    self.popoverControl.popoverContentSize = CGSizeMake(145, 300);
    [self.popoverControl presentPopoverFromRect:sender.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

- (void)didSelectFrameworkVersionAtIndexPath:(NSIndexPath *)indexPath withVersion:(Version *)version {
    if(self.popoverControl.isPopoverVisible){
        [self.popoverControl dismissPopoverAnimated:YES];
    }
#ifdef DEBUG
    NSLog(@"%@",version.number);
#endif
    Framework *framework = (self.frameworks)[self.currentlySelectedIndexPath.item];
    framework.activeVersion = version.number;
    NSManagedObjectContext *context = self.project.managedObjectContext;
    NSError *error = nil;
    if (![context save:&error]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_error_title", @"Error") message:NSLocalizedString(@"alert_error_message", @"Unable to save") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
        [errorAlert show];
#ifdef DEBUG
    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    abort();
#endif
    }
    else{
#ifdef DEBUG
    NSLog(@"Saved On Done!");
#endif
    }
    NSArray *indexPaths = @[self.currentlySelectedIndexPath];
    [self.collectionView  reloadItemsAtIndexPaths:indexPaths];
    [self.collectionView selectItemAtIndexPath:self.currentlySelectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    self.currentlySelectedIndexPath = nil;
}
    
- (BOOL)prefersStatusBarHidden {
    return YES;
}
    
    
    @end
