///------------------------------------------------------------------------------
// Copyright:   Copyright (c) Microsoft Corporation 2012
//------------------------------------------------------------------------------

#pragma once

@interface AALCredential : NSObject

@property (readonly) NSString *resource;

- (id)init:(NSString *)resource;

@end

