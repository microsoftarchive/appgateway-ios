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
#import "TabView.h"

@class TabInfo;

/*
 * Protocol for responding on tab tapping events.
 */
@protocol TabInfoDelegate <NSObject>

// Called when tab item is tapped.
- (void) tabTapped: (TabInfo*)tab;

// Called when close button on tab was tapped;
- (void) tabClosed: (TabInfo*)tab;

@end

/*
 * Tab info.
 */
@interface TabInfo : NSObject

@property (nonatomic, strong, setter=setName:) NSString* name;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong, setter=setTabView:) TabView* tabView;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, weak) id<TabInfoDelegate> delegate;
@property (nonatomic, strong) NSObject* tag;


- (id) initWithName: (NSString*) aName active:(BOOL)active tabView: (TabView*)tab contentView:(UIView*)content;

@end
