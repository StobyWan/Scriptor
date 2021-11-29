//
//  NSString+Common.m
//  Scriptor
//
//  Created by Bryan Stober on 1/10/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)


- (NSString*)html {
    NSString* html = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    return html;
}

-(BOOL)isBlank {
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

-(BOOL)contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSArray *)splitOnChar:(char)ch {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    int start = 0;
    for(int i=0; i<self.length; i++) {
        
        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == self.length - 1;
        
        if(isAtSplitChar || isAtEnd) {
            //take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;
            
            if(isAtSplitChar)
                range.length -= 1;
            
            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }
        
        //handle the case where the last character was the split char.  we need an empty trailing element in the array.
        if(isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }
    
    return results ;
}

-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}

+ (NSString *) arrayToString: (NSArray *)array {
	NSMutableString * list = [NSMutableString string];
	
	int count = (int)array.count;
	int i;
	
	for (i = 0; i < count; i++) {
		if (i + 1 == count) {
			[list appendFormat:@"%@", array[i] ];
		}
		else {
			[list appendFormat:@"%@, ", array[i] ];
		}
	}
	
	return list;
}

- (NSString *) trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*)stringBetweenString:(NSString *)start andString:(NSString *)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = self.length - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}

- (BOOL)isNumeric
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && scan.atEnd;
}

- (NSString *)toCamelCase
{
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < self.length; idx += 1)
    {
        unichar c = [self characterAtIndex:idx];
        if (c == '_')
        {
            makeNextCharacterUpperCase = YES;
        }
        else if (makeNextCharacterUpperCase)
        {
            [output appendString:[NSString stringWithCharacters:&c length:1].uppercaseString];
            makeNextCharacterUpperCase = NO;
        }
        else
        {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

- (NSString *)toUnderscore
{
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < self.length; idx += 1)
    {
        unichar c = [self characterAtIndex:idx];
        if ([uppercase characterIsMember:c])
        {
            [output appendFormat:@"_%@", [NSString stringWithCharacters:&c length:1].lowercaseString];
        }
        else
        {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}


@end
