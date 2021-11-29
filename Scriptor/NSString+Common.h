//
//  NSString+Common.h
//  Scriptor
//
//  Created by Bryan Stober on 1/10/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *html;
@property (NS_NONATOMIC_IOSONLY, getter=isBlank, readonly) BOOL blank;
- (BOOL)contains:(NSString *)string;
- (NSArray *)splitOnChar:(char)ch;
- (NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByStrippingWhitespace;
+ (NSString *) arrayToString: (NSArray *)array;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trim;
- (NSString*)stringBetweenString:(NSString *)start andString:(NSString *)end;
@property (NS_NONATOMIC_IOSONLY, getter=isNumeric, readonly) BOOL numeric;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *toCamelCase;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *toUnderscore;

@end
