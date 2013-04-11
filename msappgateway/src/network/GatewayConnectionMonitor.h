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


#import <Foundation/Foundation.h>

/*
 * Gateway connection status.
 */
typedef enum {
    GCNoNetwork = 0,
    GCNoConnection,
    GCConnected
} GatewayConnectionStatus;


/*
 * Gateway connection status listener.
 */
@protocol GatewayConnectionStatusListener <NSObject>

// Called when network connection status has changed;
- (void) connectionStatusChanged: (GatewayConnectionStatus) newStatus;

@end


/*
 * Gateway connection monitor.
 */
@interface GatewayConnectionMonitor : NSObject {
    NSMutableArray* delegates;
    NSTimer* timer;
    GatewayConnectionStatus lastStatus;
    unsigned int checkInterval;
    NSURL* _gatewayUrl;
}


@property (nonatomic, strong) NSURL* gatewayUrl;
@property (nonatomic) unsigned int checkInterval;
@property (nonatomic) GatewayConnectionStatus lastStatus;

- (id) initWithGatewayUrl: (NSURL*)url;

- (id) initWithGatewayUrl: (NSURL*)url checkInterval: (unsigned int) interval;

// Adds new status listener.
- (void) addDelegate: (id<GatewayConnectionStatusListener>) delegate;

// Removes status listener.
- (void) removeDelegate: (id<GatewayConnectionStatusListener>) delegate;

// Start monitoring connection to gateway.
- (void) startMonitoring;

// Starts monitoring gateway health with the given ping interval.
- (void) startMonitoringWithInterval: (unsigned int)interval;

// Stops monitoring.
- (void) stopMonitoring;

// Fires new update immediately.
- (void) updateStatus;

// Synchronous request to get current connection status.
+ (GatewayConnectionStatus) currentGatewayStatus: (NSURL*)gatewayUrl;

// Asynchronous request to get current network status.
+ (void) currentGatewayStatus: (NSURL*)gatewayUrl withDelegate: (id<GatewayConnectionStatusListener>)delegate;

@end
