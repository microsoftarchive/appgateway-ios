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

#import <Foundation/Foundation.h>

/*
 * Contains data about loaded web page.
 */
@interface PageInfoItem : NSObject <NSCoding> {
    NSDate* loadDate;
    NSString* name;
    NSURL* url;
}

- (id) initWithUrl: (NSURL*) anUrl name: (NSString*) aName date: (NSDate*) aDate;

@property (strong, nonatomic) NSDate* loadDate;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSURL* url;

- (BOOL) isEqual: (id)object;

@end
