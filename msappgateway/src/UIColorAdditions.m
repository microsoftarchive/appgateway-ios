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


#import "UIColorAdditions.h"

@implementation UIColor (Extended)

+ (UIColor*) colorWithHexString: (NSString*) string {
    // Trim out unnecessary characters.
    NSString* colorString = [[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String must be exact 6 symbols length.
    if (colorString.length != 6) {
        return [UIColor clearColor];
    }
    
    // Get R, G, B compontents separately.  
    NSRange range;  
    range.location = 0;  
    range.length = 2;  
    NSString *rString = [colorString substringWithRange: range];  
    
    range.location = 2;  
    NSString *gString = [colorString substringWithRange: range];  
    
    range.location = 4;  
    NSString *bString = [colorString substringWithRange: range];  
    
    // Convert compontents into integers.
    unsigned int r, g, b;  
    [[NSScanner scannerWithString: rString] scanHexInt: &r];  
    [[NSScanner scannerWithString: gString] scanHexInt: &g];  
    [[NSScanner scannerWithString: bString] scanHexInt: &b];  
    
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
}

@end
