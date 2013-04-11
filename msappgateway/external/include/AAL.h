//------------------------------------------------------------------------------
// Copyright:   Copyright (c) Microsoft Corporation 2012
//------------------------------------------------------------------------------

#pragma once

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
    #import <WebKit/WebKit.h>
#else
#error "AAL.h Error"
#endif

#import <AALCredential.h>
#import <AALAssertionCredential.h>
#import <AALUsernamePasswordCredential.h>

#import <AALAuthenticationContext.h>
