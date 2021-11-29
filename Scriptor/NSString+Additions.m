//
//  NSString+Additions.m
//  Scriptor
//
//  Created by Bryan Stober on 1/10/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//


#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString *)stringOfCharacter:(unichar)ch andLength:(int)stringLength
{
    NSMutableString* buildString = [[NSMutableString alloc] initWithCapacity:stringLength];
    NSString* charAsString = [NSString stringWithFormat:@"%C", ch];
    
    for ( int i = 0; i < stringLength; ++i )
    {
        [buildString appendString:charAsString];
    }
    
    return buildString;
}

+ (NSString *)joinListElements:(NSArray *)listValues withSeparator:(NSString *)separator
{
    NSMutableString *joinedElements = [[NSMutableString alloc] init];
    int i = 0;
    
    for( NSString *listItem in listValues )
    {
        if( i > 0 )
        {
            [joinedElements appendString:separator];
        }
        
        [joinedElements appendString:listItem];
        
        ++i;
    }
    
    return joinedElements;
}

- (BOOL)startsWith:(NSString *)prefix
{
    return [self hasPrefix:prefix];
}

- (BOOL)endsWith:(NSString *)suffix
{
    return [self hasSuffix:suffix];
}

- (NSArray *)split:(NSString *)delimiter
{
    return [self componentsSeparatedByString:delimiter];
}

- (NSArray *)splitWithCharacter:(unichar)delimiter
{
    NSString *delimiterString = [NSString stringWithFormat:@"%C", delimiter];
    return [self split:delimiterString];
}

- (NSArray *)splitLines
{
    if( self.length == 0 )
    {
        return nil;
    }
    
    NSMutableArray* listLines = [[NSMutableArray alloc] init];
    BOOL splitting = YES;
    int posCurrent = 0;
    int posCR;
    int posLF;
    NSString* substring;
    
    while( splitting )
    {
        posCR = [self indexOf:@"\r" fromOffset:posCurrent];
        posLF = [self indexOf:@"\n" fromOffset:posCurrent];
        
        if( (posCR == -1) && (posLF == -1) )  // have neither?
        {
            substring = [self substringFromIndex:posCurrent];
            if( substring.length > 0 )
            {
                [listLines addObject:substring];
            }
            
            splitting = NO;
            continue;
        }
        else if( posCR > -1 && posLF > -1 )  // have both?
        {
            const int distanceBetweenMarkers = abs(posLF - posCR);
            
            if( posCR < posLF )  // CR occurs first?
            {
                [listLines addObject:[self substringWithRange:NSMakeRange(posCurrent,posCR-posCurrent)]];
                
                if( distanceBetweenMarkers == 1 ) // are the markers back-to-back?
                {
                    posCurrent = posLF + 1;
                }
                else
                {
                    posCurrent = posCR + 1;
                }
            }
            else  // LF occurs first
            {
                [listLines addObject:[self substringWithRange:NSMakeRange(posCurrent,posLF-posCurrent)]];
                
                if( distanceBetweenMarkers == 1 ) // are the markers back-to-back?
                {
                    posCurrent = posCR + 1;
                }
                else
                {
                    posCurrent = posLF + 1;
                }
            }
        }
        else if( posCR > -1 )  // have CR?
        {
            [listLines addObject:[self substringWithRange:NSMakeRange(posCurrent,posCR-posCurrent)]];
            posCurrent = posCR + 1;
        }
        else   // have LF
        {
            [listLines addObject:[self substringWithRange:NSMakeRange(posCurrent,posLF-posCurrent)]];
            posCurrent = posLF + 1;
        }
    }
    
    return listLines;
}

- (BOOL)contains:(NSString *)substring
{
    NSRange textRange = [self rangeOfString:substring];
    return( textRange.location != NSNotFound );
}

- (BOOL)containsCharacter:(unichar)ch
{
    NSString *stringWithCharacter = [NSString stringWithFormat:@"%C", ch];
    return [self contains:stringWithCharacter];
}

- (BOOL)isEmpty
{
    return( self.length == 0 );
}

- (NSString *)padLeft:(int)paddedLength
{
    return [self padLeft:paddedLength paddingChar:' '];
}

- (NSString *)padLeft:(int)paddedLength paddingChar:(unichar)paddingChar
{
    // does it even need to be padded?
    if( self.length >= paddedLength )
    {
        // doesn't need padding, return unmodified
        return self;
    }
    
    const int paddingCharsNeeded = paddedLength - self.length;
    
    NSMutableString* paddedString =
    [[NSMutableString alloc] initWithCapacity:paddedLength];
    NSString* paddedCharAsString = [NSString stringWithFormat:@"%C", paddingChar];
    
    for( int i = 0; i < paddingCharsNeeded; ++i )
    {
        [paddedString appendString:paddedCharAsString];
    }
    
    [paddedString appendString:self];
    
    return paddedString;
}

- (NSString *)padRight:(int)paddedLength paddingChar:(unichar)paddingChar
{
    // does it even need to be padded?
    if( self.length >= paddedLength )
    {
        // doesn't need padding, return unmodified
        return self;
    }
    
    const int paddingCharsNeeded = paddedLength - self.length;
    
    NSMutableString* paddedString =
    [[NSMutableString alloc] initWithCapacity:paddedLength];
    
    [paddedString appendString:self];
    
    NSString* paddedCharAsString = [NSString stringWithFormat:@"%C", paddingChar];
    
    for( int i = 0; i < paddingCharsNeeded; ++i )
    {
        [paddedString appendString:paddedCharAsString];
    }
    
    return paddedString;
}

- (NSString*)padRight:(int)paddedLength
{
    return [self padRight:paddedLength paddingChar:' '];
}



- (int)lastIndexOfCharacter:(unichar)character
{
    return [self lastIndexOf:[NSString stringWithFormat:@"%C",character]];
}

- (int)lastIndexOf:(NSString *)substring
{
    NSRange result = [self rangeOfString:substring options:NSBackwardsSearch];
    if( result.location == NSNotFound )
    {
        return -1;
    }
    else
    {
        return result.location;
    }
}

- (int)indexOfCharacter:(unichar)character
{
    return [self indexOf:[NSString stringWithFormat:@"%C",character]];
}



- (int)indexOf:(NSString*)substring
{
    NSRange result = [self rangeOfString:substring];
    if( result.location == NSNotFound )
    {
        return -1;
    }
    else
    {
        return result.location;
    }
}



- (int)indexOf:(NSString*)substring fromOffset:(int)offset
{
    int searchLength = self.length-offset;
    NSRange result = [self rangeOfString:substring
                                 options:NSLiteralSearch
                                   range:NSMakeRange(offset,searchLength)];
    if( result.location == NSNotFound )
    {
        return -1;
    }
    else
    {
        return result.location;
    }
}



- (int)indexOfAny:(NSString*)stringOfCharsToSearchFor
{
    return [self indexOfAny:stringOfCharsToSearchFor fromOffset:0];
}



- (int)indexOfAny:(NSString*)stringOfCharsToSearchFor fromOffset:(int)offset
{
    const int stringLength = self.length;
    int firstCharPosition = stringLength;
    
    const int numberCharacters = stringOfCharsToSearchFor.length;
    unichar charToSearch;
    NSString* stringToSearch;
    int posFound;
    
    for( int i = 0; i < numberCharacters; ++i )
    {
        charToSearch = [stringOfCharsToSearchFor characterAtIndex:i];
        stringToSearch = [NSString stringWithFormat:@"%C", charToSearch];
        
        posFound = [self indexOf:stringToSearch fromOffset:offset];
        if( posFound > -1 )
        {
            if( posFound < firstCharPosition )
            {
                firstCharPosition = posFound;
            }
        }
    }
    
    if( firstCharPosition == stringLength )
    {
        // none were found
        return -1;
    }
    else
    {
        return firstCharPosition;
    }
}



- (BOOL)isEqualToStringCaseInsensitive:(NSString*)compareString
{
    NSComparisonResult res = [self caseInsensitiveCompare:compareString];
    return( res == NSOrderedSame );
}

- (BOOL)isLessThan:(NSString*)compareString
{
    NSComparisonResult compareResult = [self compare:compareString];
    return( compareResult == NSOrderedAscending );
}



- (BOOL)isGreaterThan:(NSString*)compareString
{
    NSComparisonResult compareResult = [self compare:compareString];
    return( compareResult == NSOrderedDescending );
}



- (BOOL)isLessThanOrEqual:(NSString*)compareString
{
    NSComparisonResult compareResult = [self compare:compareString];
    return( compareResult != NSOrderedDescending );
}



- (BOOL)isGreaterThanOrEqual:(NSString*)compareString
{
    NSComparisonResult compareResult = [self compare:compareString];
    return( compareResult != NSOrderedAscending );
}



- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (int)findFirstNotOf:(unichar)charToSearch
{
    const int length = self.length;
    unichar currentChar;
    
    for( int i = 0; i < length; ++i )
    {
        currentChar = [self characterAtIndex:i];
        if( currentChar != charToSearch )
        {
            return i;
        }
    }
    
    return -1;
}

- (int)findFirstOf:(unichar)charToSearch
{
    const int length = self.length;
    unichar currentChar;
    
    for( int i = 0; i < length; ++i )
    {
        currentChar = [self characterAtIndex:i];
        if( currentChar == charToSearch )
        {
            return i;
        }
    }
    
    return -1;
}

- (int)findLastOf:(unichar)charToSearch
{
    const int length = self.length;
    unichar currentChar;
    
    for( int i = length-1; i >= 0; --i )
    {
        currentChar = [self characterAtIndex:i];
        if( currentChar == charToSearch )
        {
            return i;
        }
    }
    
    return -1;
}

- (int)findLastNotOf:(unichar)charToSearch
{
    const int length = self.length;
    unichar currentChar;
    
    for( int i = length-1; i >= 0; --i )
    {
        currentChar = [self characterAtIndex:i];
        if( currentChar != charToSearch )
        {
            return i;
        }
    }
    
    return -1;
}

- (NSString*)trim:(unichar)charToTrim
{
    NSString* stringWithChar = [[NSString alloc] initWithFormat:@"%C", charToTrim];
    NSString * res = [self stringByTrimmingCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:stringWithChar]];
    return res;
}



- (NSString*)trimStart
{
    return [self trimStart:' '];
}

- (NSString*)trimStart:(unichar)charToTrim
{
    const int numChars = self.length;
    
    if( numChars == 0 )
    {
        return self;
    }
    
    int numCharsToTrim = 0;
    unichar currentChar;
    
    // start inspecting chars from left until we find one that isn't
    // the character to trim
    for( int i = 0; i < numChars; ++i )
    {
        currentChar = [self characterAtIndex:i];
        
        if( currentChar == charToTrim )
        {
            ++numCharsToTrim;
        }
        else
        {
            break;
        }
    }
    
    if( numCharsToTrim == numChars )
    {
        // the entire string contains the character to trim, so we
        // return an empty string
        return @"";
    }
    else if( numCharsToTrim == 0 )
    {
        // no characters to trim
        return self;
    }
    else
    {
        // some characters to trim
        return [self substringFromIndex:numCharsToTrim];
    }
}

- (NSString*)trimEnd
{
    return [self trimEnd:' '];
}

- (NSString*)trimEnd:(unichar)charToTrim
{
    const int indexLastNotOfTrimChar = [self findLastNotOf:charToTrim];
    if( indexLastNotOfTrimChar > -1 )
    {
        return [self substringToIndex:indexLastNotOfTrimChar+1];
    }
    else
    {
        // the entire string contains the character to trim, so we
        // return an empty string
        return @"";
    }
}

- (unichar)firstCharacter
{
    return [self characterAtIndex:0];
}



- (unichar)lastCharacter
{
    return [self characterAtIndex:self.length - 1];
}



- (NSString*)replaceAll:(NSString*)searchFor replaceWith:(NSString*)replaceWith
{
    return [self stringByReplacingOccurrencesOfString:searchFor
                                           withString:replaceWith];
}



- (int)hexValue
{
    int n = 0;
	sscanf(self.UTF8String, "%x", &n);
	return n;
}

-(NSString *) reverseString {
    NSMutableString *reversedStr;
    int len = self.length;
    
    // Auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];     
    
    // Probably woefully inefficient...
    while (len > 0)
        [reversedStr appendString:
         [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];   
    
    return reversedStr;
}

- (NSUInteger)countOccurenceOf:(NSString *)s
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return 0;
    }
    NSUInteger nsi = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return nsi;
}


- (BOOL)beginsWith:(NSString *)s
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return NO;
    }
    NSUInteger nsi = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (nsi == 1) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)upperFirstLetter:(NSString *)s {
    return [s stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[s substringToIndex:1].capitalizedString];
}

@end

