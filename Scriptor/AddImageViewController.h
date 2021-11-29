//
//  AddImageViewController.h
//  Scriptor
//
//  Created by Bryan Stober on 1/30/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddImageViewControllerDelegate <NSObject>

- (void)didAddImageWithUrl:(NSString*)url;

@end

@interface AddImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) id<AddImageViewControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)addImageAction:(UIButton *)sender;

@end
