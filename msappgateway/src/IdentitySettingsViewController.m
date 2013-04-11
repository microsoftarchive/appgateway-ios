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

#import <AAL.h>

#import "IdentitySettingsViewController.h"

@interface IdentitySettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* doneButton;

@end

//
// Change the behavior for keyboard dismissal for our navigation controller
//
@implementation UINavigationController (DelegateAutomaticKeyboardDismissal)

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return [[self topViewController] disablesAutomaticKeyboardDismissal];
}

@end

@implementation IdentitySettingsViewController
{
    UILabel *_status;
}

@synthesize delegate = _delegate;
@synthesize username = _username;
@synthesize password = _password;
@synthesize statusButton = _statusButton;
@synthesize indicatorView = _indicatorView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_username)
    {
        [_usernameField setText:_username];
    }
    if (_password)
    {
        [_passwordField setText:_password];
    }
    if (_cancelDisabled)
    {
        [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
    }
    if (!(_username && _password)) {
        _doneButton.enabled = NO;
    }
    
    _status = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [_status setBackgroundColor:[UIColor clearColor]];
    [_status setTextColor:[UIColor darkGrayColor]];
    [_status setFont:[UIFont systemFontOfSize:14.0]];
    [_status setText:@""];
    [_statusButton setCustomView:_status];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _status = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Allow keyboard to be dissmissed

- (BOOL)disablesAutomaticKeyboardDismissal
{
    // by default the keyboard is not allowed to be dismissed when a modal form sheet is displayed on iPad
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _usernameField)
    {
        [_passwordField becomeFirstResponder];
    }
    else if (textField == _passwordField)
    {
        [self done:textField];
    }
    return YES;
}

- (IBAction)textFieldChanged:(id)sender {
    if ((_passwordField.text.length > 0) && (_usernameField.text.length > 0)) {
        _doneButton.enabled = YES;
    } else {
        _doneButton.enabled = NO;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_usernameField becomeFirstResponder];
}

#pragma mark - Actions for navigation bar buttons

- (IBAction)done:(id)sender
{
    if (![[self view] endEditing:NO])
    {
        return;
    }

    NSString *username = [_usernameField text];
    NSString *password = [_passwordField text];
    BOOL needsVerification = YES;
    if ([username length] && [username isEqualToString:_username] && [password isEqualToString:_password])
    {
        needsVerification = NO;
    }
    
    if (needsVerification)
    {
        if (![username length])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid User Name"
                                                            message:@"User name cannot be empty"
                                                           delegate:self
                                                  cancelButtonTitle:@"Back"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [_indicatorView startAnimating];
        [_status setText:@"Signing in"];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 200.0 * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            // Verify that the user creds are valid first
            AALAuthenticationContext *context = [[AALAuthenticationContext alloc] init];
            AALUsernamePasswordCredential *credential = [[AALUsernamePasswordCredential alloc] init:@"Application Gateway"
                                                                                           username:username
                                                                                           password:password];
            AALAssertionCredential *token = [context acquireToken:[_settings orgIdRPName] credential:credential];
            
            [_indicatorView stopAnimating];

            if (token == nil)
            {
                [_status setText:@""];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials"
                                                                message:@"The entered credentials are invalid"
                                                               delegate:self
                                                      cancelButtonTitle:@"Back"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                // If we get here we know the user creds are okay
                [_status setText:@"Signed in"];

                dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, 200.0 * NSEC_PER_MSEC);
                dispatch_after(popTime1, dispatch_get_main_queue(), ^{
                    [_delegate identitySettings:self DidFinishWithUsername:username password:password];
                });
            }
        });
    }
    else
    {
        [_delegate identitySettings:self DidFinishWithUsername:username password:password];
    }

}

- (IBAction)cancel:(id)sender
{
    [_delegate identitySettingsDidCancel:self];
}

- (IBAction)helpUrlClicked:(id)sender {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://go.microsoft.com/fwlink/?LinkID=272099&clcid=0x409"]];
}

@end
