//
//  JSONLoader.h
//  JSONHandler
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONLoader : NSObject

// Return an array of Location objects from the json file at location given by url
- (NSArray *)locationsFromJSONFile:(NSURL *)url;

@end
