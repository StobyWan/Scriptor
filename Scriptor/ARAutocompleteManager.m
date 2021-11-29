//
//  ARAutocompleteManager.m
//  alexruperez
//
//  Created by Alejandro Rupérez on 12/6/12.
//  Copyright (c) 2013 alexruperez. All rights reserved.
//

#import "ARAutocompleteManager.h"

static ARAutocompleteManager *sharedManager;

@implementation ARAutocompleteManager

+ (ARAutocompleteManager *)sharedManager
{
	static dispatch_once_t done;
	dispatch_once(&done, ^{ sharedManager = [[ARAutocompleteManager alloc] init]; });
	return sharedManager;
}

#pragma mark - ARAutocompleteTextViewDelegate

- (NSString *)textView:(ARAutocompleteTextView *)textView
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase{
    if (textView.autocompleteType == ARAutocompleteTypeNames)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray *colorAutocompleteArray;
        dispatch_once(&colorOnceToken, ^
        {
            colorAutocompleteArray = @[ @"Alfred",
                                        @"Beth",
                                        @"Carlos",
                                        @"Daniel",
                                        @"Ethan",
                                        @"Fred",
                                        @"George",
                                        @"Helen",
                                        @"Inis",
                                        @"Jennifer",
                                        @"Kylie",
                                        @"Liam",
                                        @"Melissa",
                                        @"Noah",
                                        @"Omar",
                                        @"Penelope",
                                        @"Quan",
                                        @"Rachel",
                                        @"Seth",
                                        @"Timothy",
                                        @"Ulga",
                                        @"Vanessa",
                                        @"William",
                                        @"Xao",
                                        @"Yilton",
                                        @"Zander"];
        });

        NSString *stringToLookFor;
		NSArray *componentsString = [prefix componentsSeparatedByString:@","];
        NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (ignoreCase)
        {
            stringToLookFor = prefixLastComponent.lowercaseString;
        }
        else
        {
            stringToLookFor = prefixLastComponent;
        }
        
        for (NSString *stringFromReference in colorAutocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = stringFromReference.lowercaseString;
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    
    return @"";
}

@end
