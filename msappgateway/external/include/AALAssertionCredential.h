//------------------------------------------------------------------------------
// Copyright:   Copyright (c) Microsoft Corporation 2012
//------------------------------------------------------------------------------

#pragma once

@interface AALAssertionCredential : AALCredential

@property(readonly) NSString *assertion;
@property(readonly) NSString *assertionType;

- (id)init:(NSString *)resource assertionType:(NSString *)type assertion:(NSString *)assertion;

@end
