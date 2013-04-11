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


#import "AppDelegate.h"
#import "RouterSession.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize gatewayConnectionMonitor = _monitor;

+ (AppDelegate*)instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RouterSettings registerDefaults];
    RouterSettings* settings = [[RouterSettings alloc] init];
    [settings loadSettings];
    
    // Setup connection monitor
    NSString* routerUrlString = [NSString stringWithFormat: @"%@%@:%d", BrowserConnectProtocol, settings.hostname, settings.adminPort];
    NSURL* routerUrl = [NSURL URLWithString:routerUrlString];
    _monitor = [[GatewayConnectionMonitor alloc] initWithGatewayUrl:routerUrl];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [_monitor stopMonitoring];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [_monitor updateStatus];
    [_monitor startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
