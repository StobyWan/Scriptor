//
//  CDN.m
//  Scriptor
//
//  Created by Bryan Stober on 1/6/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "FrameworkJSON.h"

@implementation FrameworkJSON

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        NSString *integer = jsonDictionary[@"heirarchy"];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterNoStyle;
        NSNumber * myNumber = [f numberFromString:integer];
        _timeStamp = nil;
        _name = jsonDictionary[@"name"];
        _snippet = jsonDictionary[@"snippet"];
        _site = jsonDictionary[@"site"];
        _imageName =jsonDictionary[@"image"];
        _versions = [NSArray arrayWithArray:jsonDictionary[@"versions"]];
        _heirarchy = myNumber;
        _activeVersion = jsonDictionary[@"activeVersion"];// _versions[0];
        _isActive = NO;
    }
    
    return self;
}

@end
