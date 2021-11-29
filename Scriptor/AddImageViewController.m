//
//  AddImageViewController.m
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "AddImageViewController.h"

@interface AddImageViewController ()

@end

@implementation AddImageViewController

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
	self.textLabel.text = NSLocalizedString(@"image_url_label", @"Image URL:");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addImageAction:(UIButton *)sender {
         [self.delegate didAddImageWithUrl:self.urlTextField.text];
}
@end
