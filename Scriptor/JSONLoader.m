//
//  JSONLoader.m
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "JSONLoader.h"
#import "FrameworkJSON.h"

@implementation JSONLoader

- (NSArray *)locationsFromJSONFile:(NSURL *)url {
    // Create a NSURLRequest with the given URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    // Get the data
    NSURLResponse *response;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    // Now create a NSDictionary from the JSON data
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    // Create a new array to hold the locations
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // Get an array of dictionaries with the key "locations"
    NSArray *array = jsonDictionary[@"cdns"];
    // Iterate through the array of dictionaries
    for(NSDictionary *dict in array) {
        // Create a new Location object for each one and initialise it with information in the dictionary
        FrameworkJSON *frameworkJSON = [[FrameworkJSON alloc] initWithJSONDictionary:dict];
        // Add the Location object to the array
        [items addObject:frameworkJSON];
    }
    // Return the array of Location objects
    return items;
}

@end
