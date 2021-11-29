//
//  NSString+Additions.h
//  Scriptor
//
//  Created by Bryan Stober on 1/10/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *URLEncodedString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *URLDecodedString;

@end
