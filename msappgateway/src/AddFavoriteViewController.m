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


#import "AddFavoriteViewController.h"

@interface AddFavoriteViewController ()
@end

@implementation AddFavoriteViewController

@synthesize delegate = _delegate;
@synthesize bookmarkName = _bookmarkName;
@synthesize bookmarkUrl = _bookmarkUrl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancel)]];
    [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target:self action:@selector(done)]];
    
    self.nameField.text = self.bookmarkName;
    self.urlField.text = self.bookmarkUrl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBookmarkName:(NSString *)bookmarkName
{
    _bookmarkName = bookmarkName;
    [_nameField setText:_bookmarkName];
}

- (void)setBookmarkUrl:(NSString *)bookmarkUrl
{
    _bookmarkUrl = bookmarkUrl;
    [_urlField setText:_bookmarkUrl];
}

- (void) cancel {
    if (_delegate != nil) {
        [_delegate viewControllerDidCancel: self];
    }
}

- (void) done {
    if (_delegate != nil) {
        [_delegate viewControllerDidReturn: self withName: self.nameField.text url: self.urlField.text];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != _urlField) return YES;
    
    [self done];
    return YES;
}

@end
