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


#import "TabView.h"

@implementation TabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) awakeFromNib {
    UIImage* backgroundImageOrig = [UIImage imageNamed:@"tab_inactive.png"];
    UIImage* backgroundImageActiveOrig = [UIImage imageNamed:@"tab_active.png"];    
    UIEdgeInsets insets = UIEdgeInsetsMake(10, backgroundImageOrig.size.width/2, 10, backgroundImageOrig.size.width/2);
    
    UIImage* backgroundImage = nil;
    if ([backgroundImageOrig respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        backgroundImage =  [backgroundImageOrig resizableImageWithCapInsets: insets resizingMode: UIImageResizingModeStretch];
    } else {
        backgroundImage = [backgroundImageOrig resizableImageWithCapInsets: insets];
    }

    UIImage* backgroundImageActive = nil;

    if ([backgroundImageActiveOrig respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        backgroundImageActive = [backgroundImageActiveOrig resizableImageWithCapInsets: insets resizingMode: UIImageResizingModeStretch];
    } else {
        backgroundImageActive = [backgroundImageActiveOrig resizableImageWithCapInsets: insets];
    }
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:backgroundImage highlightedImage:backgroundImageActive];
    CGRect imgFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    imgView.frame = imgFrame;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    imgView.autoresizesSubviews = NO;
    [self insertSubview:imgView belowSubview: _nameLabel];
    _background = imgView;
}

- (void) layoutSubviews {
    CGRect imgFrame = _background.frame;
    imgFrame.size.width = self.frame.size.width;
    [_background setFrame: imgFrame];
}

@end
