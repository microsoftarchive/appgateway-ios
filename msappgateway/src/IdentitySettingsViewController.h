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

#import "RouterSettings.h"

@protocol IdentitySettingsViewControllerDelegate;

@interface IdentitySettingsViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) id <IdentitySettingsViewControllerDelegate> delegate;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
@property (nonatomic) BOOL cancelDisabled;
@property (nonatomic) RouterSettings *settings;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusButton;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)textFieldChanged:(id)sender;
- (IBAction)helpUrlClicked:(id)sender;

@end

@protocol IdentitySettingsViewControllerDelegate <NSObject>

- (void)identitySettings:(IdentitySettingsViewController *)settings DidFinishWithUsername:(NSString *)username password:(NSString*)password;
- (void)identitySettingsDidCancel:(IdentitySettingsViewController *)settings;

@end
