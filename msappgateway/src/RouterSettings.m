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

#import "RouterSettings.h"

NSString * const RouterHostnameKey = @"RouterHostname";
NSString * const RouterBrowserPortKey = @"RouterBrowserPort";
NSString * const RouterAdminPortKey = @"RouterAdminPort";
NSString * const RouterOrgIdRPNameKey = @"RouterOrgIdRPName";

@interface RouterSettings ()

- (id)initWithSettings:(RouterSettings *)settings;

@end

@implementation RouterSettings

+ (void)registerDefaults
{
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"DefaultSettings"
                                                                                               withExtension:@"plist"]];
    if (defaults)
    {
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}

- (id)initWithSettings:(RouterSettings *)settings
{
    self = [super init];
    if (self)
    {
        _hostname = [settings hostname];
        _browserPort = [settings browserPort];
        _adminPort = [settings adminPort];
        _orgIdRPName = [settings orgIdRPName];
    }
    return self;
}

- (id)init
{
    return [self initWithSettings:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[RouterSettings allocWithZone:zone] initWithSettings:self];
}

- (void)loadSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _hostname = [userDefaults stringForKey:RouterHostnameKey];
    _browserPort = [userDefaults integerForKey:RouterBrowserPortKey];
    _adminPort = [userDefaults integerForKey:RouterAdminPortKey];
    _orgIdRPName = [userDefaults stringForKey:RouterOrgIdRPNameKey];
}

- (void)saveSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_hostname forKey:RouterHostnameKey];
    [userDefaults setInteger:_browserPort forKey:RouterBrowserPortKey];
    [userDefaults setInteger:_adminPort forKey:RouterAdminPortKey];
    [userDefaults setObject:_orgIdRPName forKey:RouterOrgIdRPNameKey];

    [userDefaults synchronize];
}

@end
