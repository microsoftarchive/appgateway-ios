//------------------------------------------------------------------------------
// Copyright:   Copyright (c) Microsoft Corporation 2012
//------------------------------------------------------------------------------

#pragma once

@interface AALUsernamePasswordCredential : AALCredential

@property (readonly) NSString *username;
@property (readonly) NSString *password;

- (id)init:(NSString *)resource username:(NSString *)username password:(NSString *)password;

@end
