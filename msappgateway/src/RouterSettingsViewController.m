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


#import "RouterSettingsViewController.h"

@interface RouterSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *hostname;
@property (weak, nonatomic) IBOutlet UITextField *browserPort;
@property (weak, nonatomic) IBOutlet UITextField *adminPort;
@property (weak, nonatomic) IBOutlet UITextField *orgIdName;

@end

@implementation RouterSettingsViewController

@synthesize hostname = _hostname;
@synthesize browserPort = _browserPort;
@synthesize adminPort = _adminPort;
@synthesize orgIdName = _orgIdName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_settings)
    {
        [_hostname setText:[_settings hostname]];
        [_browserPort setText:[NSString stringWithFormat:@"%d", [_settings browserPort]]];
        [_adminPort setText:[NSString stringWithFormat:@"%d", [_settings adminPort]]];
        [_orgIdName setText:[_settings orgIdRPName]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setSettings:(RouterSettings *)settings
{
    _settings = settings;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _adminPort && [[textField text] isEqualToString:@""])
    {
        [textField setText:[_browserPort text]];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _hostname)
    {
        [_browserPort becomeFirstResponder];
    }
    else if (textField == _browserPort)
    {
        [_adminPort becomeFirstResponder];
    }
    else if (textField == _adminPort)
    {
        [_orgIdName becomeFirstResponder];
    }
    else if (textField == _orgIdName)
    {
        [self done:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _browserPort || textField == _adminPort)
    {
        if ([string length] && ![string integerValue] && ![string isEqualToString:@"0"])
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (![[_hostname text] length])
    {
        [_hostname becomeFirstResponder];
    }
    else
    {
        [_orgIdName becomeFirstResponder];
    }
}

#pragma mark - Actions for navigation bar buttons
- (IBAction)done:(id)sender
{
    NSString *hostname = [_hostname text];
    NSInteger browserPort = [[_browserPort text] integerValue];
    NSInteger adminPort = [[_adminPort text] integerValue];
    NSString *orgIdName = [_orgIdName text];

    if (![hostname length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Host Name"
                                                        message:@"Host Name field must be specified."
                                                       delegate:self
                                              cancelButtonTitle:@"Back"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [_settings setHostname:hostname];

    if (![orgIdName length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid OrgId Name"
                                                        message:@"OrgId Name field must be specified."
                                                       delegate:self
                                              cancelButtonTitle:@"Back"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [_settings setOrgIdRPName:orgIdName];

    if (!browserPort)
    {
        browserPort = 80;
    }
    if (!adminPort)
    {
        adminPort = browserPort;
    }
    [_settings setBrowserPort:browserPort];
    [_settings setAdminPort:adminPort];

    [_delegate routerSettings:self didFinishWithSettings:_settings];
}

- (IBAction)cancel:(id)sender
{
    [_delegate routerSettingsDidCancel:self];
}

@end
