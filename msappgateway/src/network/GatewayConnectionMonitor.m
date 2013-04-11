/*
 *  Copyright (c) Microsoft Open Technologies
 *  All rights reserved. 
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. 
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
 *  THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT 
 *  LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE, 
 *  MERCHANTABLITY OR NON-INFRINGEMENT. 
 *  See the Apache Version 2.0 License for specific language governing permissions and limitations under the License.
 */



#import "GatewayConnectionMonitor.h"
#import "Reachability.h"

#define kDefaultNetworkTestHost @"http://www.google.com"
#define kDefaultTimeoutInterval 10
#define kGatewayAliveStatusKode 200
#define kDefaultPingInterval    15

/*
 * Private helpers.
 */
@interface GatewayConnectionMonitor (Private)

@end

@implementation GatewayConnectionMonitor

@synthesize lastStatus;
@synthesize checkInterval;
@synthesize gatewayUrl = _gatewayUrl;

- (id) init {
    self = [super init];
    if (self) {
        delegates = [[NSMutableArray alloc] init];
        lastStatus = GCNoNetwork;
        checkInterval = kDefaultPingInterval;
    }
    return self;
}

- (id) initWithGatewayUrl: (NSURL*)url {
    self = [self init];
    if (self) {
        _gatewayUrl = url;
    }
    return self;
}

- (id) initWithGatewayUrl: (NSURL*)url checkInterval: (unsigned int) interval {
    self = [self initWithGatewayUrl: url];
    if (self) {
        checkInterval = interval;
    }
    return self;
}

// Adds new status listener.
- (void) addDelegate: (id<GatewayConnectionStatusListener>) delegate {
    if ([delegates indexOfObject: delegate] == NSNotFound) {
        [delegates addObject: delegate];
    }
}

// Removes status listener.
- (void) removeDelegate: (id<GatewayConnectionStatusListener>) delegate {
    if ([delegates indexOfObject: delegate] != NSNotFound) {
        [delegates removeObject: delegate];
    }
}

// Start monitoring connection to gateway.
- (void) startMonitoring {
    [self startMonitoringWithInterval: checkInterval];
}

// Starts monitoring gateway health with the given ping interval.
- (void) startMonitoringWithInterval: (unsigned int)interval {
    checkInterval = interval;
    if (timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:checkInterval
                                             target:self
                                           selector:@selector(updateStatus)
                                           userInfo:nil
                                            repeats:YES];
}

// Stops monitoring.
- (void) stopMonitoring {
    [timer invalidate];
    timer = nil;
}

// Fires new update immediately.
- (void) updateStatus {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        GatewayConnectionStatus status = [GatewayConnectionMonitor currentGatewayStatus: _gatewayUrl];
        lastStatus = status;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<GatewayConnectionStatusListener> delegate in delegates) {
                [delegate connectionStatusChanged: status];
            }
        });
    });
}

#pragma mark - Static helpers

// Synchronous request to get current connection status.
+ (GatewayConnectionStatus) currentGatewayStatus: (NSURL*)gatewayUrl {
    
    // Check network connection first
    NSURL *url = [NSURL URLWithString: kDefaultNetworkTestHost];
    NetworkStatus remoteHostStatus = [[Reachability reachabilityWithHostName:[url host]] currentReachabilityStatus];
    
    // Return if there is no network connection
    if (remoteHostStatus == NotReachable) {
        return GCNoNetwork;
    }
    
    // Now check the gateway health
    NSError* error;
    NSURL* gatewayStatusUrl = [gatewayUrl URLByAppendingPathComponent:@"status"];
    NSURLRequest* request = [NSURLRequest requestWithURL: gatewayStatusUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: kDefaultTimeoutInterval];
    NSHTTPURLResponse* response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // If gateway returned 200 then it is alive.
    if (response != nil) {
        if ([response statusCode] == kGatewayAliveStatusKode) {
            return GCConnected;
        }
    }
    
    // Otherwise there is some problem with the connection or gateway.
    return GCNoConnection;
}

// Asynchronous request to get current network status.
+ (void) currentGatewayStatus: (NSURL*)gatewayUrl withDelegate: (id<GatewayConnectionStatusListener>)delegate {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        GatewayConnectionStatus status = [self currentGatewayStatus: gatewayUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate != nil) {
                [delegate connectionStatusChanged: status];
            }
        });
    });
}

@end
