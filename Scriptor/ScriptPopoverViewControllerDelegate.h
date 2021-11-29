//
//  ScriptPopoverViewControllerDelegate.h
//  Scriptor
//
//  Created by Bryan Stober on 1/13/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Version;

@protocol ScriptPopoverViewControllerDelegate <NSObject>

- (void)didSelectFrameworkVersionAtIndexPath:(NSIndexPath *)indexPath withVersion:(Version *)version;

@end
