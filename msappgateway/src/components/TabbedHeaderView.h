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

#import <UIKit/UIKit.h>
#import "TabInfo.h"

/*
 * Tabs changing delegate.
 */
@protocol TabbedHeaderViewDelegate <NSObject>

// Called when tab becomes activated.
- (void) tabActivated: (TabInfo*) tab;

// Called when user wants to open new tab.
- (void) newTabRequested;

@end

@interface TabbedHeaderView : UIScrollView <TabInfoDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray* tabs;
@property (nonatomic, weak) id<TabbedHeaderViewDelegate> tabbedHeaderDelegate;

- (void) addTab: (NSString*) name active: (BOOL) active tag:(NSObject*) obj;
- (void) addTab: (NSString*) name active: (BOOL) active tag:(NSObject*) obj contentView:(UIView*)view;
- (void) addTab: (TabInfo*) tab;
- (void) removeTab: (TabInfo*) tabInfo;
- (void) removeTabAtIndex: (NSInteger) index;
- (void) removeAllTabs;
- (void) setActiveTab: (TabInfo*) tabInfo;
- (TabInfo*) activeTab;
- (TabInfo*) tabWithIndex:(NSInteger)index;

- (void) updateForOrientation:(UIInterfaceOrientation)orientation;
- (void) updateFromOrientation:(UIInterfaceOrientation)orientation;

- (IBAction)newTab:(id)sender;

@end
