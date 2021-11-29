//
//  NSString+Additions.h
//  Scriptor
//
//  Created by Bryan Stober on 1/10/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//


@interface NSString (Additions)

+ (NSString*)stringOfCharacter:(unichar)ch andLength:(int)stringLength;
+ (NSString*)joinListElements:(NSArray*)listValues withSeparator:(NSString*)separator;
+ (NSString *)upperFirstLetter:(NSString *)s;

- (BOOL)startsWith:(NSString*)prefix;
- (BOOL)endsWith:(NSString*)suffix;
- (NSArray*)split:(NSString*)delimiter;
- (NSArray*)splitWithCharacter:(unichar)delimiter;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *splitLines;
- (BOOL)contains:(NSString*)substring;
- (BOOL)containsCharacter:(unichar)ch;
@property (NS_NONATOMIC_IOSONLY, getter=isEmpty, readonly) BOOL empty;
- (NSString*)padLeft:(int)paddedLength;
- (NSString*)padLeft:(int)paddedLength paddingChar:(unichar)paddingChar;
- (NSString*)padRight:(int)paddedLength paddingChar:(unichar)paddingChar;
- (NSString*)padRight:(int)paddedLength;
- (int)lastIndexOfCharacter:(unichar)character;
- (int)lastIndexOf:(NSString*)substring;
- (int)indexOfCharacter:(unichar)character;
- (int)indexOf:(NSString*)substring;
- (int)indexOf:(NSString*)substring fromOffset:(int)offset;
- (int)indexOfAny:(NSString*)stringOfCharsToSearchFor;
- (int)indexOfAny:(NSString*)stringOfCharsToSearchFor fromOffset:(int)offset;
- (BOOL)isEqualToStringCaseInsensitive:(NSString*)compareString;
- (BOOL)isLessThan:(NSString*)compareString;
- (BOOL)isGreaterThan:(NSString*)compareString;
- (BOOL)isLessThanOrEqual:(NSString*)compareString;
- (BOOL)isGreaterThanOrEqual:(NSString*)compareString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trim;
- (NSString*)trim:(unichar)charToTrim;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trimStart;
- (NSString*)trimStart:(unichar)charToTrim;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trimEnd;
- (NSString*)trimEnd:(unichar)charToTrim;
- (int)findFirstNotOf:(unichar)charToSearch;
- (int)findFirstOf:(unichar)charToSearch;
- (int)findLastOf:(unichar)charToSearch;
- (int)findLastNotOf:(unichar)charToSearch;
@property (NS_NONATOMIC_IOSONLY, readonly) unichar firstCharacter;
@property (NS_NONATOMIC_IOSONLY, readonly) unichar lastCharacter;
- (NSString*)replaceAll:(NSString*)searchFor replaceWith:(NSString*)replaceWith;
@property (NS_NONATOMIC_IOSONLY, readonly) int hexValue;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *reverseString;
- (BOOL)beginsWith:(NSString *)s;
- (NSUInteger)countOccurenceOf:(NSString *)s;
@end

@interface NSMutableString (MutableStringAdditions)

- (void)appendCharacter:(unichar)aCharacter;

@end
