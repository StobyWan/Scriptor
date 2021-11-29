//
//  DetailViewControllerDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/12/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

@required

- (void)detailViewControllerDidAddImageToProject:(DetailViewController*)view;

@optional

- (void)detailViewDidOpenWebView:(id)view;

@end
