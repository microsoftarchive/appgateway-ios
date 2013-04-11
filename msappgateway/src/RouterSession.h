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

NSString * const BrowserConnectProtocol;

//
// NSError codes and info keys
//
NSString * const RouterCommunicationErrorDomain;
const NSInteger InvalidStatusCodeError;
const NSInteger InvalidContentTypeError;
const NSInteger MissingListOfAgentsError;
const NSInteger MissingAgentIdError;
const NSInteger MissingSessionIdError;

NSString * const ErrorStatusCodeKey;

@interface RouterSession : NSObject

@property (readonly) NSString *username;
@property (readonly) NSString *password;
@property (readonly) NSString *sessionId;
@property (readonly) NSString *agentId;
@property (nonatomic, retain) NSString *displayName;

@property (nonatomic, copy) RouterSettings *settings;

- (BOOL)isConfigured;
- (void)configureUsername:(NSString *)username password:(NSString *)password;
- (void)configureAgentId:(NSString *)agentId;
- (void)configureAgentId:(NSString *)agentId displayName: (NSString *)name;
- (void)clearUsernameAndPassword;
- (void)clearSession;

- (NSURL *)routerAdminURL;
- (NSURL *)browserConnectURLWithError:(NSError **)error;
- (NSMutableURLRequest *)createRouterRequest:(NSURL *)url error:(NSError **)error;
- (NSArray *)agentListWithError:(NSError **)error;

@end
