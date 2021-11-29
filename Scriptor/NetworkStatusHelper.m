//
//  NetworkStatusHelper.m
//  Scriptor
//
//  Created by Bryan Stober on 1/29/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import "NetworkStatusHelper.h"
#import "Reachability.h"
#import "SynthesizeSingleton.h"

@interface NetworkStatusHelper()

@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end
@implementation NetworkStatusHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(NetworkStatusHelper)


- (BOOL)haveConnection {
    return [self haveInternetConnection] || [self haveWifiConnection];
}

- (BOOL)haveInternetConnection {
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    switch(netStatus){
        case NotReachable:
            return NO;
            
            break;
            
            
        case ReachableViaWWAN:
            return YES;
            break;
            
        case ReachableViaWiFi:
            return YES;
            break;
    }
}

- (BOOL)haveWifiConnection {
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    NetworkStatus netStatus = [self.wifiReachability currentReachabilityStatus];
    switch(netStatus){
        case NotReachable:
            return NO;
            
            break;
            
            
        case ReachableViaWWAN:
            return YES;
            break;
            
        case ReachableViaWiFi:
            return YES;
            break;
    }
}

@end
