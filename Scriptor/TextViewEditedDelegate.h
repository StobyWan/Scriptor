//
//  TextViewEditedDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/4/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol TextViewEditedDelegate <NSObject>

-(void)textViewDidFinishEditing:(id)view;

@end
