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

@class AddFavoriteViewController;

@protocol AddFavoriteViewControllerDelegate <NSObject>

- (void) viewControllerDidCancel:(AddFavoriteViewController*) viewController;

- (void) viewControllerDidReturn:(AddFavoriteViewController*) viewController withName:(NSString*) name url:(NSString*) url;

@end


@interface AddFavoriteViewController : UITableViewController

@property (nonatomic, strong) NSString* bookmarkName;
@property (nonatomic, strong) NSString* bookmarkUrl;

@property (nonatomic, weak) id<AddFavoriteViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextField* nameField;
@property (nonatomic, weak) IBOutlet UITextField* urlField;

@end
