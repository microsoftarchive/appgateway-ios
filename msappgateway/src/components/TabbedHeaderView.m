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


#import <QuartzCore/QuartzCore.h>
#import "TabbedHeaderView.h"
#import "TabView.h"
#import "TabInfo.h"

#define kTabsLeftMargin 14
#define kTabSize 260
#define kTabOverlappedSize 238
#define kFadeEdgeWidthPortrait 0.015
#define kFadeEdgeWidthLandscape 0.0075
#define kCloseTabAnimationDuration 0.3f

@interface TabbedHeaderView (Private)

// Update UI depending on number of open tabs.
- (void) checkTabsCount;

// Setup edges fading mask for given interface orientation
- (void) addFadingMaskForOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation TabbedHeaderView {
    CAGradientLayer* _maskLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tabs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        self.tabs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    self.tabs = [[NSMutableArray alloc] init];
    self.scrollEnabled = YES;
    self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    if (!_maskLayer)
    {        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.bounds = self.layer.bounds;
        gradient.position = CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2);
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
        self.layer.mask = gradient;
        gradient.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat: 0.0],
                              [NSNumber numberWithFloat: kFadeEdgeWidthPortrait],
                              [NSNumber numberWithFloat: 1-kFadeEdgeWidthPortrait],
                              [NSNumber numberWithFloat: 1.0], nil];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1.0, 0);
        
        _maskLayer = gradient;
    }
    
    [self setDelegate: self];
}

// Setup edges fading mask for given interface orientation
- (void) addFadingMaskForOrientation:(UIInterfaceOrientation)orientation {
    float fadeEdgeWidth = kFadeEdgeWidthPortrait;
    
    if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
        (orientation == UIInterfaceOrientationLandscapeRight)) {
        fadeEdgeWidth = kFadeEdgeWidthLandscape;
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.bounds = self.layer.bounds;
    gradient.position = CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    self.layer.mask = gradient;
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat: 0.0],
                          [NSNumber numberWithFloat: fadeEdgeWidth],
                          [NSNumber numberWithFloat: 1-fadeEdgeWidth],
                          [NSNumber numberWithFloat: 1.0], nil];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1.0, 0);
    
    _maskLayer = gradient;
}

- (void) addTab: (NSString*) name active: (BOOL) active tag:(NSObject*) obj {
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"TabView" owner:self options:nil];
    TabView* tabView = [nibs objectAtIndex: 0];
    tabView.autoresizesSubviews = YES;
    tabView.autoresizingMask = UIViewAutoresizingNone;
    
    TabInfo* info = [[TabInfo alloc] init];
    info.name = name;
    info.isActive = active;
    info.tabView = tabView;
    info.delegate = self;
    info.tag = obj;
    
    CGRect tabFrame = tabView.frame;
    tabFrame.size.width = kTabSize;
    [tabView setFrame: tabFrame];
    
    [_tabs addObject: info];
    [self addSubview: tabView];
    
    [self layoutSubviews];
    
    if (info.isActive) {
        [self setActiveTab: info];
    }
    
    [self checkTabsCount];
}

- (void) addTab: (NSString*) name active: (BOOL) active tag:(NSObject*) obj contentView:(UIView*)view {
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"TabView" owner:self options:nil];
    TabView* tabView = [nibs objectAtIndex: 0];
    tabView.autoresizesSubviews = YES;
    tabView.autoresizingMask = UIViewAutoresizingNone;
    
    TabInfo* info = [[TabInfo alloc] init];
    info.name = name;
    info.isActive = active;
    info.tabView = tabView;
    info.delegate = self;
    info.tag = obj;
    info.contentView = view;
    
    CGRect tabFrame = tabView.frame;
    tabFrame.size.width = kTabSize;
    [tabView setFrame: tabFrame];
    
    [_tabs addObject: info];
    [self addSubview: tabView];
    
    [self layoutSubviews];
    
    if (info.isActive) {
        [self setActiveTab: info];
    }
    
    [self checkTabsCount];
}

- (void) addTab: (TabInfo*) info {
    info.delegate = self;
    [_tabs addObject: info];
    [self addSubview: info.tabView];
    [self sendSubviewToBack: info.tabView];
    
    [self layoutSubviews];
    
    if (info.isActive) {
        [self setActiveTab: info];
    }

    [self checkTabsCount];
}

- (void) layoutSubviews {
    int offset = kTabsLeftMargin;
    for (int idx = 0; idx < _tabs.count; idx++) {
        TabInfo* tab = [_tabs objectAtIndex: idx];
        CGRect tabFrame = tab.tabView.frame;
        tabFrame.origin.x = offset;
        tabFrame.origin.y = self.frame.size.height - tabFrame.size.height;
        [tab.tabView setFrame: tabFrame];
        
        if (idx != (_tabs.count-1)) {
            offset += kTabOverlappedSize;
        } else {
            offset += kTabSize;
        }
    }
    
    self.contentSize = CGSizeMake(offset, self.frame.size.height);
}

- (void) checkTabsCount {
    if (_tabs.count == 1) {
        TabInfo* tab = [_tabs objectAtIndex: 0];
        tab.tabView.closeResponder.hidden = YES;
    }
}

- (void)tabTapped:(TabInfo *)tab {
    [self setActiveTab: tab];
}

- (void) tabClosed: (TabInfo*)tab {
    if (tab.isActive) {
        TabInfo* nextActiveTab = nil;
        int tabIndex = [_tabs indexOfObject: tab];
        if (tabIndex == 0) {
            nextActiveTab = [_tabs objectAtIndex: tabIndex+1];
        } else {
            nextActiveTab = [_tabs objectAtIndex: tabIndex-1];
        }
        [self setActiveTab: nextActiveTab];
    }

    [self removeTab: tab];
    [self checkTabsCount];
}

- (void) setActiveTab: (TabInfo*) tabInfo {
    for (int idx = _tabs.count - 1; idx >= 0; idx--) {
        TabInfo* info = [_tabs objectAtIndex:idx];
        if (info == tabInfo) {
            info.tabView.background.highlighted = YES;
            info.isActive = YES;
            info.tabView.closeResponder.hidden = NO;
            if (_tabbedHeaderDelegate) {
                [_tabbedHeaderDelegate tabActivated: info];
            }
            [self scrollRectToVisible:CGRectMake(idx * kTabOverlappedSize, 0, kTabSize, tabInfo.tabView.frame.size.height) animated:YES];
            [self bringSubviewToFront: info.tabView];
        } else {
            info.tabView.background.highlighted = NO;
            info.tabView.closeResponder.hidden = YES;
            if ((info.isActive) && (idx > 0)) {
                TabInfo* nextTab = [_tabs objectAtIndex: (idx-1)];
                [self insertSubview: info.tabView belowSubview: nextTab.tabView];
            }
            info.isActive = NO;
        }
    }
}

- (void) removeTab: (TabInfo*) tabInfo {
    int idx = [_tabs indexOfObject: tabInfo];
    if (idx != NSNotFound) {
        [tabInfo.tabView removeFromSuperview];
        [_tabs removeObject: tabInfo];
        
        for (int nextTab = idx; nextTab < _tabs.count; nextTab++) {
            TabInfo* tabInfo = [_tabs objectAtIndex: nextTab];
            CGRect frame = tabInfo.tabView.frame;
            frame.origin.x = frame.origin.x - kTabOverlappedSize;
            [UIView animateWithDuration: kCloseTabAnimationDuration animations:^{
                [tabInfo.tabView setFrame: frame];
            } completion:nil];
        }
        
        [self layoutSubviews];
    }
}

- (void) removeTabAtIndex: (NSInteger) index {
    if ((_tabs.count > index) && (index >= 0)) {
        TabInfo* tab = [_tabs objectAtIndex: index];
        [self removeTab: tab];
    }
}

- (void) removeAllTabs {
    for (TabInfo* tab in _tabs) {
        [tab.tabView removeFromSuperview];
    }
    
    [_tabs removeAllObjects];

    [self layoutSubviews];
}

- (TabInfo*) activeTab {
    for (TabInfo* info in _tabs) {
        if (info.isActive) {
            return info;
        }
    }
    
    return nil;
}

- (TabInfo*) tabWithIndex:(NSInteger)index {
    if ((index >= 0) && (index < _tabs.count)) {
        return [_tabs objectAtIndex: index];
    }
    
    return nil;
}

- (IBAction)newTab:(id)sender {
    if (_tabbedHeaderDelegate) {
        [_tabbedHeaderDelegate newTabRequested];
    }
}

- (void) updateForOrientation:(UIInterfaceOrientation)orientation {
    
    [self addFadingMaskForOrientation: orientation];
    [self layoutIfNeeded];
}

- (void) updateFromOrientation:(UIInterfaceOrientation)orientation {
    if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
        (orientation == UIInterfaceOrientationLandscapeRight)) {
        [self updateForOrientation: UIInterfaceOrientationPortrait];
    } else {
        [self updateForOrientation: UIInterfaceOrientationLandscapeLeft];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _maskLayer.position = CGPointMake([self bounds].size.width / 2 + self.contentOffset.x, [self bounds].size.height / 2);
}

@end
