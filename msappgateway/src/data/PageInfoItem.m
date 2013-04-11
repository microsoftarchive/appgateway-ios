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


#import "PageInfoItem.h"

#define kPageHistoryItemDateKey @"loadDate"
#define kPageHistoryItemNameKey @"name"
#define kPageHistoryItemUrlKey  @"url"

@implementation PageInfoItem

@synthesize loadDate;
@synthesize name;
@synthesize url;

- (id) init {
    self = [super init];
    if (self) {
        self.url = nil;
        self.name = nil;
        self.loadDate = [NSDate date];
    }
    return self;
}

- (id) initWithUrl: (NSURL*) anUrl name: (NSString*) aName date: (NSDate*) aDate {
    self = [super init];
    if (self) {
        self.url = anUrl;
        self.name = aName;
        self.loadDate = aDate;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.url      forKey: kPageHistoryItemUrlKey];
    [encoder encodeObject: self.name     forKey: kPageHistoryItemNameKey];
    [encoder encodeObject: self.loadDate forKey: kPageHistoryItemDateKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.url = [decoder decodeObjectForKey: kPageHistoryItemUrlKey];
        self.name = [decoder decodeObjectForKey: kPageHistoryItemNameKey];
        self.loadDate = [decoder decodeObjectForKey: kPageHistoryItemDateKey];
    }
    return self;
}

- (BOOL) isEqual:(id)object {
    if ([object class] != [self class]) {
        return NO;
    }
    
    PageInfoItem* item = (PageInfoItem*)object;
    if ([self.url isEqual: item.url] && ([self.name compare: item.name] == NSOrderedSame)) {
        return YES;
    }
    
    return NO;
}

@end
