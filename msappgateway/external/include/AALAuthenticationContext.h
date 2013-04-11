//------------------------------------------------------------------------------
// Copyright:   Copyright (c) Microsoft Corporation 2012
//------------------------------------------------------------------------------

#pragma once

#if TARGET_OS_IPHONE
    typedef UIViewController SysViewController;
    typedef UIWebView        SysWebView;
#elif TARGET_OS_MAC
    typedef NSViewController SysViewController;
    typedef WebView          SysWebView;
#endif

@class AALAuthenticationOptions;
@class AALAuthenticationContext;

// Callback delegate for async methods
@protocol AALAuthenticationContextDelegate <NSObject>

- (void)context:(AALAuthenticationContext *)context didFinish:(AALCredential *)credential;
- (void)context:(AALAuthenticationContext *)context didFailWithError:(NSError *)error;

@end

// Interface to the authentication subsystem.
@interface AALAuthenticationContext : NSObject
 
// This is the Org tenant initializer
- (id)init;

// Silent acquisition using various protocols. Typically, the credential is an AALUsernamePasswordCredential that is
// used to authenticate the user at their identity provider.
- (AALAssertionCredential *)acquireToken:(NSString *)targetService credential:(AALCredential *)credential;

@end
