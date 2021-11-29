//
//  NetworkStatusHelper.h
//  Scriptor
//
//  Created by Bryan Stober on 1/29/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkStatusHelper : NSObject

+ (NetworkStatusHelper *)sharedNetworkStatusHelper;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL haveConnection;

@end
