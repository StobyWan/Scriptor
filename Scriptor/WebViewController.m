//
//  WebViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.

#import "WebViewController.h"
#import "Project.h"
#import "File.h"
#import "Image.h"
#import "Constants.h"

@interface WebViewController ()
    
@property (strong, nonatomic) NSString *tempWorkingPath;
@property (strong, nonatomic) NSString *tempDirectoryName;
@property (strong, nonatomic) NSString *tempImagesDirectoryPath;
@property (strong, nonatomic) NSArray *currentBasePath;
@property (strong, nonatomic)  NSArray *files;
@property (strong, nonatomic)  NSArray *images;
@end

@implementation WebViewController
    
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int randomIndex = arc4random() % 14 + 1;
    self.webView.delegate = self;
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
    
    for (File *temp in self.files) {
        success =  [temp.data writeToFile:[self.tempWorkingPath stringByAppendingPathComponent:temp.name]
                               atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    for (Image *temp in self.images) {
        success =  [temp.imageData writeToFile:[self.tempImagesDirectoryPath stringByAppendingPathComponent:temp.imageName] atomically:YES];
    }
    
    if(success) {
        NSString *fileName = LOCAL_HTML_FILE_NAME;
        NSString *path = [self.tempWorkingPath stringByAppendingPathComponent:fileName];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSString *addition = [NSString stringWithFormat:@"?v=%f",  [NSDate date].timeIntervalSince1970];
        NSString *bUrl = [url.absoluteString stringByAppendingString:addition];
        NSURL *CUrl = [NSURL URLWithString:bUrl];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:CUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [request setHTTPShouldHandleCookies:NO];
        
        [self.webView loadRequest:request];
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
    
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSError *error = nil;
    BOOL success =[[NSFileManager defaultManager]  removeItemAtPath:self.tempWorkingPath error:&error];
    if (success) {
#ifdef DEBUG
        NSLog(@"Deleted file Success -:%@ ",error.localizedDescription)
#endif
        
        ;
    }
    else
        {
#ifdef DEBUG
        NSLog(@"Could not delete file -:%@ ",error.localizedDescription);
#endif
    }
    self.webView = nil;
}
    
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.webView = nil;
    self.currentBasePath = nil;
    self.tempWorkingPath = nil;
    self.tempDirectoryName = nil;
}
    
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.title = theTitle;
    [self.navBar pushNavigationItem:self.navigationItem animated:NO];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.webView = nil;
    self.currentBasePath = nil;
    self.tempWorkingPath = nil;
    self.tempDirectoryName = nil;
}
    
- (IBAction)done:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
    
- (BOOL)prefersStatusBarHidden {
    return YES;
}
    
@end
