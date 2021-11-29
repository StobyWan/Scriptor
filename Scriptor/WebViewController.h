//
//  WebViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <UIKit/UIKit.h>

@class Project;
@class File;
@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Project *project;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) File *file;

@end
