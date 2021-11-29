//
//  ARAutocompleteManager.h
//  alexruperez
//
//  Created by Alejandro Rupérez on 12/6/12.
//  Copyright (c) 2013 alexruperez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARAutocompleteTextView.h"

typedef NS_ENUM(unsigned int, ARAutocompleteType) {
    ARAutocompleteTypeNames,
};

@interface ARAutocompleteManager : NSObject <ARAutocompleteDataSource>

+ (ARAutocompleteManager *)sharedManager;

@end
