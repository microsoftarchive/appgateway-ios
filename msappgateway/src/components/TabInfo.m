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


#import "TabInfo.h"

@implementation TabInfo

- (id) initWithName: (NSString*) aName active:(BOOL)active tabView: (TabView*)tab contentView:(UIView*)content {
    self = [super init];
    if (self) {
        self.name = aName;
        self.isActive = active;
        self.tabView = tab;
        self.contentView = content;
        
        if (_tabView) {
            // Add event listeners for buttons.
            [_tabView.responder addTarget: self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [_tabView.closeResponder addTarget: self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            _tabView.nameLabel.text = _name;
        }
    }
    return self;
}

- (void) setTabView: (TabView*) tabView {
    _tabView = tabView;
    [_tabView.responder addTarget: self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tabView.closeResponder addTarget: self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _tabView.nameLabel.text = _name;
}

- (void)setName:(NSString *)name {
    _name = name;
    _tabView.nameLabel.text = name;
}

- (void) tapped: (id) sender {
    if (_delegate) {
        [_delegate tabTapped: self];
    }
}

- (void) closeTapped: (id) sender {
    if (_delegate) {
        [_delegate tabClosed: self];
    }
}

@end
