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


#import "SettingsMenuController.h"
#import "IdentitySettingsViewController.h"
#import "RouterSettingsViewController.h"
#import "AddFavoriteViewController.h"
#import "PageListViewControllerDelegate.h"
#import "GatewayConnectionMonitor.h"
#import "AgentListViewController.h"
#import "TabbedHeaderView.h"

@class PageInfoItem;
@class TabbedHeaderView;

@interface ViewController : UIViewController <UITextFieldDelegate,
    UIWebViewDelegate,
    UIAlertViewDelegate,
    SettingsMenuControllerDelegate,
    IdentitySettingsViewControllerDelegate,
    RouterSettingsViewControllerDelegate,
    AddFavoriteViewControllerDelegate,
    PageListViewControllerDelegate,
    GatewayConnectionStatusListener,
    AgentListViewControllerDelegate,
    TabbedHeaderViewDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITextField *urlText;

// don't make this weak because we allocate a new UIWebView when the user signs out
@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *forward;
@property (weak, nonatomic) IBOutlet UIButton *favorites;
@property (weak, nonatomic) IBOutlet UIButton *addFavorite;
@property (weak, nonatomic) IBOutlet UIButton *settings;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *settingsPlaceholder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *addFavoritePlaceholder;
@property (weak, nonatomic) IBOutlet TabbedHeaderView *header;

// This cannot be weak because we put it out of the toolbar when loading a page
@property (nonatomic) IBOutlet UIButton *refreshButton;
@property (nonatomic) IBOutlet UIButton *cancelButton;

// Initial loading activity indicator.
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)showSettings:(id)sender;
- (IBAction)showFavorites:(id)sender;
- (IBAction)showAddFavorite:(id)sender;

- (IBAction)urlFieldChanged:(id)sender;

@end
