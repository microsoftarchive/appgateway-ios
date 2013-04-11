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


#import <AAL.h>

#import "RouterSession.h"

@interface RouterSession ()

- (NSURL*)routerConfigPath;
- (void)readRouterConfiguration;
- (BOOL)storeRouterConfiguration;

- (NSString *)firstAgentIdWithError:(NSError **)error;
- (AALAssertionCredential *)getToken;

@end

NSString * const UserNameKey = @"username";
NSString * const PasswordKey = @"password";
NSString * const AgentIdKey = @"agent_id";
NSString * const DisplayNameKey = @"display_name";
NSString * const ConfigFilename = @"router_config.plist";

NSString * const BrowserConnectPathFormat = @"/connect/browser/%@";
NSString * const BrowserConnectProtocol = @"https://";

NSString * const AuthenticationHeaderName = @"x-bhut-authN-token";
NSString * const UserIdHeaderName = @"x-bhut-user-id";

//
// NSError codes and info keys
//
NSString * const RouterCommunicationErrorDomain = @"Router Communication";
const NSInteger InvalidStatusCodeError = 1;
const NSInteger InvalidContentTypeError = 2;
const NSInteger MissingListOfAgentsError = 3;
const NSInteger MissingAgentIdError = 4;
const NSInteger MissingSessionIdError = 5;

NSString * const ErrorStatusCodeKey = @"StatusCode";

@implementation RouterSession
{
    int _sessionTTL;
    RouterSettings *_settings;
}

@synthesize sessionId = _sessionId;
@synthesize username = _username;
@synthesize password = _password;
@synthesize agentId = _agentId;
@synthesize displayName = _displayName;

- (RouterSession*)init
{
    self = [super init];
    if (self)
    {
        _settings = [[RouterSettings alloc] init];
        [_settings loadSettings];

        [self readRouterConfiguration];
    }
    return self;
}

#pragma mark - Persistent configuration implementation

- (NSURL*)routerConfigPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *path = [fileManager URLForDirectory:NSApplicationSupportDirectory
                                      inDomain:NSUserDomainMask
                             appropriateForURL:nil
                                        create:YES
                                         error:nil];
    if (!path)
    {
        @throw [NSException exceptionWithName:@"NoApplicationSupportDirectory"
                                       reason:@"Cannot determine location of application support directory"
                                     userInfo:nil];
    }
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    path = [path URLByAppendingPathComponent:bundleId];
    if (![fileManager fileExistsAtPath:[path path]])
    {
        if (![fileManager createDirectoryAtURL:path withIntermediateDirectories:YES attributes:nil error:nil])
        {
            @throw [NSException exceptionWithName:@"InvalidApplicationSupportDirectory"
                                           reason:@"Cannot create configuration directory"
                                         userInfo:nil];
        }
    }
        
    return [path URLByAppendingPathComponent:ConfigFilename];
}

- (void)readRouterConfiguration
{
    NSData *data = [NSData dataWithContentsOfURL:[self routerConfigPath]];
    if (data)
    {
        id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
        _username = [plist objectForKey:UserNameKey];
        _password = [plist objectForKey:PasswordKey];
        _displayName = [plist objectForKey:DisplayNameKey];
        _agentId = [plist objectForKey:AgentIdKey];
    }
}

- (BOOL)storeRouterConfiguration
{
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithCapacity:2];
    if (_username) [plist setObject:_username forKey:UserNameKey];
    if (_password) [plist setObject:_password forKey:PasswordKey];
    if (_displayName) [plist setObject:_displayName forKey:DisplayNameKey];
    if (_agentId) [plist setObject:_agentId forKey:AgentIdKey];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];

    // Make sure the file contents is encrypted because we're storing a password in it
    NSMutableDictionary *fileAttrs = [NSMutableDictionary dictionaryWithCapacity:1];
    [fileAttrs setObject:NSFileProtectionComplete forKey:NSFileProtectionKey];

    return [[NSFileManager defaultManager] createFileAtPath:[[self routerConfigPath] path] contents:data attributes:fileAttrs];
}

- (void)configureUsername:(NSString *)username password:(NSString *)password
{
    _username = username;
    _password = password;

    // Clear the session and agent IDs because we might have a new user now
    _sessionId = nil;
    _displayName = nil;
    _agentId = nil;
    
    if (![self storeRouterConfiguration])
    {
        NSLog(@"[%@ %@] Failed to store router configuration", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}

- (void)configureAgentId:(NSString *)agentId
{
    _agentId = agentId;
    if (![self storeRouterConfiguration])
    {
        NSLog(@"[%@ %@] Failed to store router configuration", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    _sessionId = nil;
}

- (void)configureAgentId:(NSString *)agentId displayName: (NSString *)name {
    _displayName = name;

    [self configureAgentId:agentId];
}

- (void)clearUsernameAndPassword
{
    _username = nil;
    _password = nil;
    _agentId = nil;
    _displayName = nil;

    if (![self storeRouterConfiguration])
    {
        NSLog(@"[%@ %@] Failed to store router configuration", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}

- (BOOL)isConfigured
{
    return (_username != nil && [_username length] > 0);
}

- (void)clearSession
{
    _sessionId = nil;
}

#pragma mark - Settings property

- (void)setSettings:(RouterSettings *)settings
{
    _settings = [settings copy];
    [_settings saveSettings];

    // Clear the session and agent ID and remove it from the pesistent configuration
    _sessionId = nil;
    _agentId = nil;
    _displayName = nil;
    [self storeRouterConfiguration];
}

- (RouterSettings *)settings
{
    return [_settings copy];
}

#pragma mark - OrgId authentication

- (AALAssertionCredential *)getToken
{
    // Verify that the user creds are valid first
    AALAuthenticationContext *context = [[AALAuthenticationContext alloc] init];
    AALUsernamePasswordCredential *credential = [[AALUsernamePasswordCredential alloc] init:@"Application Gateway"
                                                                                   username:_username
                                                                                   password:_password];
    // hardcode the RP URL for now until we get our own for the router service
    return [context acquireToken:[_settings orgIdRPName] credential:credential];
}

#pragma mark - HTTP client support

- (NSString *)headerValue:(NSString *)name inResponse:(NSHTTPURLResponse *)resp
{
    NSDictionary *headers = [resp allHeaderFields];
    for (NSString *header in [headers allKeys])
    {
        if ([header caseInsensitiveCompare:name] == NSOrderedSame)
            return [headers objectForKey:header];
    }
    return nil;
}

- (NSMutableURLRequest *)createRouterRequest:(NSURL *)url error:(NSError **)error
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    AALAssertionCredential *token = [self getToken];
    if (!token)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"Authentication Failure" code:1 userInfo:nil];
        }
        return nil;
    }
    [req setValue:[token assertion] forHTTPHeaderField:AuthenticationHeaderName];
    return req;
}

- (NSData *)sendRequest:(NSURLRequest *)req error:(NSError **)error
{
    NSHTTPURLResponse *resp;
    NSData *respData = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:error];
    if ([resp statusCode] != 200)
    {
        NSLog(@"[%@ %@] Router returned status code %u", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [resp statusCode]);
        if (error)
        {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
            [info setObject:[NSString stringWithFormat:@"Unexpected return code %u", [resp statusCode]] forKey:NSLocalizedDescriptionKey];
            [info setObject:[NSNumber numberWithInteger:[resp statusCode]] forKey:ErrorStatusCodeKey];
            *error = [NSError errorWithDomain:RouterCommunicationErrorDomain code:InvalidStatusCodeError userInfo:info];
        }
        return nil;
    }
    NSString *contentType = [self headerValue:@"content-type" inResponse:resp];
    NSRange range = [contentType rangeOfString:@";"];
    if (range.location != NSNotFound)
    {
        contentType = [contentType substringToIndex:range.location];
    }
    if (!contentType || [contentType caseInsensitiveCompare:@"application/json"] != NSOrderedSame)
    {
        NSLog(@"[%@ %@] Invalid content-type '%@', expecting 'application/json'", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), contentType);
        if (error)
        {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
            [info setObject:@"Invalid content-type header" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RouterCommunicationErrorDomain code:InvalidContentTypeError userInfo:info];
        }
        return nil;
    }
    return respData;
}


- (NSData *)routerGetConnection:(NSURL *)url error:(NSError **)error
{
    NSMutableURLRequest *req = [self createRouterRequest:url error:error];
    if (!req)
    {
        return nil;
    }
    return [self sendRequest:req error:error];
}

- (NSData *)routerPostConnection:(NSURL *)url withData:(NSData *)data error:(NSError **)error
{
    NSMutableURLRequest *req = [self createRouterRequest:url error:error];
    if (!req)
    {
        return nil;
    }
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [req setHTTPBody:data];
    return [self sendRequest:req error:error];
}

#pragma mark - Router URLs

- (NSURL *)routerAdminURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@:%d", BrowserConnectProtocol,
                                 [_settings hostname], [_settings adminPort]]];
}

- (NSURL *)browserConnectURLWithError:(NSError **)error
{
    NSString *sessionId = [self sessionIdWithError:error];
    if (!sessionId)
    {
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:BrowserConnectPathFormat, sessionId];
    NSString *url = [NSString stringWithFormat:@"%@%@:%d%@", BrowserConnectProtocol,
                     [_settings hostname], [_settings browserPort], path];
    return [NSURL URLWithString:url];
}

#pragma mark - Router API

- (NSArray *)agentListWithError:(NSError **)error
{
    NSURL *url = [[self routerAdminURL] URLByAppendingPathComponent:@"user/agents"];
    
    // Send the request
    NSData *resp = [self routerGetConnection:url error:error];
    if (!resp)
    {
        return nil;
    }
    
    // Parse the response body
    id data = [NSJSONSerialization JSONObjectWithData:resp options:0 error:error];
    if (!data)
    {
        NSLog(@"[%@ %@] Cannot parse router /user/agents response, error = %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), *error);
        return nil;
    }
    if ([data isKindOfClass:[NSDictionary class]])
    {
        id agents = [data objectForKey:@"agents"];
        if ([agents isKindOfClass:[NSArray class]])
        {
            return agents;
        }
    }

    NSLog(@"[%@ %@] Failed to find the list of agents in the router response.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (error)
    {
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
        [info setObject:@"Missing list of available agents" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:RouterCommunicationErrorDomain code:MissingListOfAgentsError userInfo:info];
    }
    return nil;
}

- (NSString *)firstAgentIdWithError:(NSError **)error
{
    NSString *agentId = nil;
    NSString *displayName = nil;
    NSArray *agents = [self agentListWithError:error];
    id agent = [agents objectAtIndex:0];
    if ([agent isKindOfClass:[NSDictionary class]])
    {
        agentId = [agent objectForKey:@"agent_id"];
        displayName = [agent objectForKey:@"display_name"];
    }
    if (!agentId)
    {
        NSLog(@"Failed to parse the router response to /user/agents");
        if (error)
        {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
            [info setObject:@"No registered agents found." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RouterCommunicationErrorDomain code:MissingAgentIdError userInfo:info];
        }
    }
    _displayName = displayName;
    return agentId;
}

- (NSString *)sessionIdWithError:(NSError **)error
{
    if (_sessionId)
    {
        return _sessionId;
    }
    if (![self isConfigured])
    {
        return nil;
    }
    if (!_agentId)
    {
        _agentId = [self firstAgentIdWithError:error];
        if (!_agentId)
        {
            return nil;
        }
    }

    // Create the request message
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:_agentId forKey:@"agent_id"];
    NSData *reqData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:error];
    if (!reqData)
    {
        NSLog(@"[%@ %@] Cannot generate JSON request for /user/session, error = %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), *error);
        return nil;
    }

    // Send the request
    NSData *respData = [self routerPostConnection:[[self routerAdminURL] URLByAppendingPathComponent:@"user/session"] withData:reqData error:error];
    if (!respData)
    {
        return nil;
    }

    // Parse the response body
    id data = [NSJSONSerialization JSONObjectWithData:respData options:0 error:error];
    if (!data)
    {
        NSLog(@"[%@ %@] Cannot parse router /user/session response, error = %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), *error);
        return nil;
    }
    if ([data isKindOfClass:[NSDictionary class]])
    {
        _sessionId = [data objectForKey:@"session_id"];
        NSLog(@"[%@ %@] We have a session with id = '%@'", NSStringFromClass([self class]), NSStringFromSelector(_cmd), _sessionId);
        NSNumber *ttl = [data objectForKey:@"ttl"];
        _sessionTTL = [ttl intValue];
    }
    if (!_sessionId)
    {
        NSLog(@"Failed to parse the router response to /user/session");
        if (error)
        {
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:1];
            [info setObject:@"Cannot establish sesssion with the agent." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RouterCommunicationErrorDomain code:MissingSessionIdError userInfo:info];
        }
    }

    return _sessionId;
}

- (NSString *)sessionId
{
    return [self sessionIdWithError:NULL];
}

@end
