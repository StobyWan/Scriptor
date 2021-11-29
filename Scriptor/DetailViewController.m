//
//  DetailViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <SSZipArchive.h>
#import "DetailViewController.h"
#import "FrameworksViewController.h"
#import "WebViewController.h"
#import "NSString+Additions.h"
#import "Project.h"
#import "File.h"
#import "Image.h"
#import "Constants.h"
#import "NSString+Additions.h"


@interface DetailViewController () <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString *tempWorkingPath;
@property (strong, nonatomic) NSString *tempDirectoryName;
@property (strong, nonatomic) NSString *tempZipPath;
@property (strong, nonatomic) NSArray *currentBasePath;
@property (weak, nonatomic) NSString *feedbackMsg;
@property (weak, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) UIBarButtonItem *emailButton;
@property (strong, nonatomic) NSString *tempImagesDirectoryPath;
@property (strong, nonatomic)  NSArray *files;
@property (strong, nonatomic)  NSArray *images;

- (void)configureView;

@end

@implementation DetailViewController

#pragma mark - Managing the Project item

- (void)setProject:(id)project {
    if (_project != project) {
        _project = project;
        [self configureView];
    }
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)setMasterViewController:(MasterViewController *)view {
    if (_masterViewController != view) {
        _masterViewController = view;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = SCRIPTOR_LIGHT_LIGHT_YELLOW;
    self.toolBar.barStyle = UIBarStyleDefault;
    self.toolBar.barTintColor = SCRIPTOR_LIGHT_LIGHT_YELLOW;
    [self registerNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(frameWorksViewControllerClosed:)
                                                 name:FrameworksViewControllerWasCreatedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    self.navigationController.navigationBar.translucent = YES;
    [self.segmentedOutlet setTintColor:SCRIPTOR_DARK_GREY];
    self.masterViewController.delegate = self;
    self.screenName = @"IDE Screen";
    self.introTextView.text = NSLocalizedString(@"intro_vc_intro_text", @"info_text");
    self.emailButton = self.toolBar.items[0];
    
    //    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
    //    }
    //    else{
    //
    //    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unRegisterNotifications];
}

- (void)setUpViewType{
    switch (self.segmentedOutlet.selectedSegmentIndex) {
        case ViewTypeHTML:
            self.type = @(ViewTypeHTML);
            break;
        case ViewTypeCSS:
            self.type = @(ViewTypeCSS);
            break;
        case ViewTypeJS:
            self.type = @(ViewTypeJS);
            break;
        default:
            self.type = @(ViewTypeHTML);
            break;
    }
}

- (void)defaultsDidChange:(NSNotification *)notification{
    [self configureView];
}

- (void)configureView {
    
    if (self.project) {
        self.infoView.hidden = YES;
        self.textView.hidden = NO;
        self.textView.tag = 101;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_COLOR_SCHEME_KEY] isEqualToString:@"Light"]) {
            self.textView.backgroundColor = SCRIPTOR_LIGHT_LIGHT_YELLOW;
            [self.textView setTextColor:SCRIPTOR_DARK_GREY];
        }
        else{
            self.textView.backgroundColor = SCRIPTOR_DARK_GREY;
            [self.textView setTextColor:SCRIPTOR_YELLOW_TEXT];
        }
        [self setUpViewType];
        self.segmentedOutlet.alpha = 1.0;
        self.segmentedOutlet.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.emailButton.enabled = YES;
        self.view.backgroundColor = SCRIPTOR_YELLOW;
        self.textView.delegate = self;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        NSArray * files = [NSArray arrayWithArray:[self.project.files sortedArrayUsingDescriptors:sortDescriptors]];
        _file = files[(self.type).integerValue];
        NSString *content = [self.file.data copy];
        
        if (![content isEmpty] && (self.type).integerValue == ViewTypeHTML) {
            content = [self requireJSScriptTagInText:content withText:self.project.findTags];
            content =[content stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        }
        
        if ([self.project.isNewScript  isEqual: @1] && (self.type).integerValue == ViewTypeHTML) {
            content = [content stringByReplacingOccurrencesOfString:self.project.findTags withString:self.project.scriptTags];
            self.project.isNewScript = @0;
            self.project.findTags = self.project.scriptTags;
            self.textView.text = content;
            [self saveTextField];
        }
        else{
            self.textView.text = content;
        }
    }
    else{
        self.infoView.hidden =NO;
        self.textView.hidden =YES;
        self.segmentedOutlet.alpha = 0.0;
        self.segmentedOutlet.userInteractionEnabled = NO;
        self.navigationController.navigationItem.rightBarButtonItem  = nil;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.emailButton.enabled = NO;
    }
}

#pragma mark - Segmented Control Methods

- (IBAction)segmentToggle:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == ViewTypeHTML)
    {
        [self saveTextField];
        self.type = [NSNumber numberWithInt:ViewTypeHTML];
    }
    else if(sender.selectedSegmentIndex == ViewTypeCSS)
    {
        [self saveTextField];
        self.type = [NSNumber numberWithInt:ViewTypeCSS];
    }
    else if(sender.selectedSegmentIndex == ViewTypeJS)
    {
        [self saveTextField];
        self.type = [NSNumber numberWithInt:ViewTypeJS];
    }
    [self configureView];
}

#pragma mark - String Utility

-(NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)aRange {
    
    return aRange;
}

- (NSString*)requireJSScriptTagInText:(NSString*)aText withText:(NSString*)bText {
    
    if (aText !=nil && bText != nil) {
        
        if (![aText contains:bText]) {
#ifdef DEBUG
            NSLog(@"String did not contain String");
#endif
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"html_vc_error_alert_title", @"Error")  message:NSLocalizedString(@"html_vc_error_alert_message", @"You have Altered the script tags!Please remove script tags from The Frameworks Selection Page. They will be reinserted...") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok", @"ok") otherButtonTitles:nil, nil];
            [alert show];
            
            aText = [NSString stringWithFormat:@"<!doctype html>\n<html>\n<head>\n<meta charset\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width\" />\n<title>Title</title>\n<link rel=\"stylesheet\" href=\"style.css\" />\n%@</head>\n<body>\n</body>\n</html>", self.project.findTags];
        }
    }
    return aText;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"project", @"Project");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"WebViewSegue"]){
        [self saveTextField];
        ((WebViewController *) segue.destinationViewController).project = self.project;
    }
    if ([segue.identifier isEqualToString:@"settingsPopover"]) {
        [self unRegisterNotifications];
        self.popoverControl = ((UIStoryboardPopoverSegue *)segue).popoverController;
        self.popoverControl.delegate = self;
        
    }
    if ([segue.identifier isEqualToString:@"ADDIMAGE"]) {
        [self unRegisterNotifications];
        AddImageViewController *addImageViewController =(AddImageViewController*) segue.destinationViewController;
        addImageViewController.delegate = self;
        self.popoverControl = ((UIStoryboardPopoverSegue *)segue).popoverController;
        self.popoverControl.delegate = self;
        
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.popoverControl.isPopoverVisible) {
        [self.popoverControl dismissPopoverAnimated:NO];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [self registerNotifications];
    return YES;
}

#pragma mark - MasterViewControllerDelegate Methods

- (void)masterViewControllerReportsNoObjects:(id)view {
    self.project = nil;
    [self configureView];
}

#pragma mark - FrameworksViewController Notifications

- (void)frameWorksViewControllerClosed:(NSNotification *)note {
    _project = (Project *)note.object;
    [self configureView];
}

#pragma mark Export Server Methods

- (IBAction)exportPackageServerFolder:(UIBarButtonItem *)sender {
    
#ifdef DEBUG
    NSLog(@"Exported");
#endif
    int randomIndex = arc4random() % 14 + 1;
    self.currentBasePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.tempDirectoryName = [NSString stringWithFormat:@"%@-%i",self.project.folderId,randomIndex];
    self.tempWorkingPath = [self.currentBasePath[0] stringByAppendingPathComponent:self.tempDirectoryName];
    NSString *imagesPath = @"images";
    self.tempImagesDirectoryPath =[self.tempWorkingPath stringByAppendingPathComponent:imagesPath];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.tempWorkingPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.tempWorkingPath withIntermediateDirectories:NO attributes:nil error:&error];
        if(![[NSFileManager defaultManager] fileExistsAtPath:self.tempImagesDirectoryPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:self.tempImagesDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
    }
    BOOL success = false;
    
    _files = [self loadFiles];
    _images = [self loadImages];
    
    NSMutableArray *folderArray = [[NSMutableArray alloc] init];
    for (File *temp in self.files) {
        success =  [temp.data writeToFile:[self.tempWorkingPath stringByAppendingPathComponent:temp.name]
                               atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSString *resource = [NSString stringWithFormat:@"%@/%@",self.tempWorkingPath,temp.name];
        [folderArray addObject:resource];
    }
    for (Image *temp in self.images) {
        success =  [temp.imageData writeToFile:[self.tempImagesDirectoryPath stringByAppendingPathComponent:temp.imageName] atomically:YES];
        NSString *resource = [NSString stringWithFormat:@"%@/%@",self.tempImagesDirectoryPath,temp.imageName];
        [folderArray addObject:resource];
    }
    if (success) {
        NSString *name = self.project.name;
        if (name == nil || [name isEqualToString:@""]) {
            name = @"project";
        }
        _tempZipPath = [NSString stringWithFormat:@"%@/%@.zip",self.currentBasePath[0],name];
        [self zipFileFromPath:self.tempWorkingPath toPath:self.tempZipPath];
    }
}

- (NSArray*)loadFiles {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray * files = [NSArray arrayWithArray:[self.project.files sortedArrayUsingDescriptors:sortDescriptors]];
    return files;
}

- (NSArray*)loadImages {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imageName" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray * images = [NSArray arrayWithArray:[self.project.images sortedArrayUsingDescriptors:sortDescriptors]];
    return images;
}

- (void)zipFileFromPath:(NSString *)sourcePath toPath:(NSString*)destinationPath {
    
    [SSZipArchive createZipFileAtPath:destinationPath withContentsOfDirectory:sourcePath];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
    
    if (fileExists) {
        
        NSURL *url = [NSURL fileURLWithPath:destinationPath];
        NSArray *objectsToShare = @[url];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        // Exclude all activities except AirDrop.
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
        controller.completionWithItemsHandler = ^(NSString *act, BOOL done, NSArray *returnedItems, NSError *error) {
#ifdef DEBUG
            NSLog(@"act type %@",act);
#endif
            NSString *ServiceMsg = nil;
            if ( [act isEqualToString:UIActivityTypeMail] ){
                ServiceMsg = NSLocalizedString(@"details_vc_alert_title_mail_sent", @"Mail sent!") ;
            }
            if ( [act isEqualToString:UIActivityTypeMessage] ) {
                ServiceMsg = NSLocalizedString(@"details_vc_alert_title_message_sent", @"Message sent!");
            }
            if ( [act isEqualToString:UIActivityTypeAirDrop] ) {
                ServiceMsg =NSLocalizedString(@"details_vc_alert_title_airdrop_sent", @"AirDrop sent!") ;
            }
            
            
            if ( done )
            {
                [self deleteZipAtPath:self.tempWorkingPath];
                [self deleteZipAtPath:self.tempZipPath];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok",  @"ok") otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [self deleteZipAtPath:self.tempWorkingPath];
                [self deleteZipAtPath:self.tempZipPath];
                
            }
        };
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"detail_vc_alert_title_project_zip", @"Project Zip") message:NSLocalizedString(@"detail_vc_alert_message_project_zip", @"An Error Occured While Zipping this Project!") delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok",  @"ok") otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)activityDidFinish:(BOOL)completed{
    
    
}
- (void)unzipFileFromPath:(NSString*)sourcePath toPath:(NSString*)destinationPath {
    [SSZipArchive unzipFileAtPath:sourcePath toDestination:destinationPath];
}

- (BOOL)deleteZipAtPath:(NSString*)path {
    NSError *error = nil;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (self.textView.inputAccessoryView == nil) {
        
        self.textView.inputAccessoryView = self.accessoryView;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
    if (![self.textView.text  isEqualToString:@""] && self.textView.tag == 101) {
        [self saveTextField];
    }
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)unRegisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    const NSDictionary *const userInfo = notification.userInfo;
    
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    int height = CGRectGetHeight(keyboardRect);
    self.userInteractionViewBottomConstraint.constant = height;
    [self.textView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.textView layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    const NSDictionary *const userInfo = notification.userInfo;
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    self.userInteractionViewBottomConstraint.constant = 8;
    [self.textView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.textView layoutIfNeeded];
    }];
    
    if (![self.textView.text  isEqualToString:@""] && self.textView.tag == 101) {
        [self saveTextField];
    }
}

- (IBAction)buttonPressed:(UIButton *)sender {
    
    NSRange range = self.textView.selectedRange;
    NSString * firstHalfString = [self.textView.text substringToIndex:range.location];
    NSString * secondHalfString = [self.textView.text substringFromIndex: range.location];
    self.textView.scrollEnabled = NO;
    NSString * insertingString = sender.currentTitle;
    self.textView.text = [NSString stringWithFormat: @"%@%@%@", firstHalfString,insertingString,secondHalfString];
    range.location += insertingString.length;
    self.textView.selectedRange = range;
    self.textView.scrollEnabled = YES;
}

- (void)saveTextField {
    if ((self.type).integerValue == ViewTypeHTML) {
        if (self.textView != nil) {
            self.textView.text = [self requireJSScriptTagInText:self.textView.text withText:self.project.findTags];
        }
    }
    self.project.lastModified = [NSDate date];
    self.file.data = self.textView.text;
    NSManagedObjectContext *context = self.project.managedObjectContext;
    NSError *error = nil;
    if (![context save:&error]) {
#ifdef DEBUG
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
#endif
    }
    else{
#ifdef DEBUG
        NSLog(@"textView - Saved - Type = %@",self.type);
#endif
    }
}

- (void)dealloc {
    [self unRegisterNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FrameworksViewControllerWasCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)didAddImageWithUrl:(NSString *)url{
    [self.popoverControl dismissPopoverAnimated:YES];
    [self saveImageFromURL:url];
}

- (void)saveImageFromURL:(NSString*)url {
    
    NSString *message = nil;
    NSURL *candidateURL = [NSURL URLWithString:url];
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        if (image) {
            
#ifdef DEBUG
            NSLog(@"Downloading...");
            NSLog(@"%f,%f",image.size.width,image.size.height);
            NSLog(@"saving png");
#endif
            NSData *data = nil;
            NSString *fileName = url.lastPathComponent;
            NSArray *fileNameArray = [fileName  componentsSeparatedByString:@"."];
            NSMutableArray *fileNameMutableArray = [NSMutableArray arrayWithArray:fileNameArray];
            if (fileNameMutableArray.count == 2) {
                if([fileNameMutableArray[1] isEqualToString:@"jpg"]){
                    data = [NSData dataWithData:UIImageJPEGRepresentation(image,100.0f)];
                }
                if([fileNameMutableArray[1] isEqualToString:@"jpeg"]){
                    data = [NSData dataWithData:UIImageJPEGRepresentation(image,100.0f)];
                }
                if([fileNameMutableArray[1] isEqualToString:@"png"]){
                    data = [NSData dataWithData:UIImagePNGRepresentation(image)];
                }
                if([fileNameMutableArray[1] isEqualToString:@"gif"]){
                    data = [NSData dataWithData:UIImagePNGRepresentation(image)];
                }
                if([fileNameMutableArray[1] isEqualToString:@"svg"]){
                    data = [NSData dataWithData:UIImagePNGRepresentation(image)];
                }
            }
            else{
                
                message = @"This is not a valid image file";
                [self activateAlertForImageImportWithMessage:message];
                return;
            }
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.project.managedObjectContext];
            Image *imagex = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.project.managedObjectContext];
            imagex.imageName = url.lastPathComponent;
            imagex.imageData = data;
            imagex.imageType = 0;
            [self.project addImagesObject:imagex];
            NSManagedObjectContext *context = self.project.managedObjectContext;
            NSError *error = nil;
            if (![context save:&error]) {
#ifdef DEBUG
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
#endif
                
            }
            else{
#ifdef DEBUG
                NSLog(@"Image - Saved - Type = %@ - Name = %@",imagex.imageType, imagex.imageName);
#endif
                message = NSLocalizedString(@"valid_url", @"You succesfully imported this image");
                [self activateAlertForImageImportWithMessage:message];
                return;
            }
        }
        else{
            message = NSLocalizedString(@"no_image",  @"This url does supply an image...");
            [self activateAlertForImageImportWithMessage:message];
            return;
        }
    }
    else{
#ifdef DEBUG
        NSLog(@"Bad Url! <<------>>");
#endif
        message = NSLocalizedString(@"not_valid_url", @"This is not a valid URL!") ;
        [self activateAlertForImageImportWithMessage:message];
        return;
    }
}

- (void)activateAlertForImageImportWithMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"image_import_alert_title", @"Image Import")  message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"master_vc_ok",@"ok") otherButtonTitles:nil, nil];
    [alert show];
}

@end
