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


#import "ViewController.h"
#import "RouterSession.h"
#import "AddFavoriteViewController.h"
#import "PageInfoItem.h"
#import "BookmarkManager.h"
#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "TabbedHeaderView.h"

#define kSpinnerDefaultOffset 25
#define kSpinnerEditingOffset 50

@interface ViewController ()

- (NSURL *)routerURL:(NSString *)userUrl error:(NSError **)error;
- (NSString *)userURL:(NSURL *)routerUrl;

// Moves spinner view to prevent overlapping with URL field's 'clear' button.
- (void) setSpinnerTabbed:(BOOL)flag;

// Loads agent list and displays help page if it's empty.
- (void) checkAgentList;

// Shows local page with link to the MS OpenTech help page.
- (void) displayHelpPage;

@end

@implementation ViewController
{
    UIPopoverController *_settingsPopoverController;
    UIPopoverController *_addFavoritePopoverController;
    RouterSession *_session;
    UIBarButtonItem *_stopButton;
    BOOL _stoppedLoading;
    BOOL _sessionRenewal;
    GatewayConnectionMonitor* _connectionMonitor;
    BOOL _showingInvalidConnectionAlertView;
}

@synthesize urlText = _urlText;
@synthesize webView = _webView;
@synthesize back = _back;
@synthesize forward = _forward;
@synthesize settingsPlaceholder = _settingsPlaceholder;
@synthesize refreshButton = _refreshButton;
@synthesize toolbar = _toolbar;
@synthesize spinner = _spinner;
@synthesize addFavoritePlaceholder = _addFavoritePlaceholder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_back setEnabled:NO];
    [_forward setEnabled:NO];

    _session = [[RouterSession alloc] init];
    
    CGRect spinnerFrame = _spinner.frame;
    spinnerFrame.origin.x = _urlText.frame.origin.x + _urlText.frame.size.width - kSpinnerEditingOffset;
    _cancelButton.frame  = spinnerFrame;
    
    _stopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [_stopButton setStyle: UIBarButtonItemStylePlain];
    [_stopButton setWidth:40];
    [_stopButton setImageInsets: UIEdgeInsetsMake(2, 0, -2, 0)];

    SettingsMenuController *settingsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"SettingsController"];
    [settingsController setDelegate:self];
    _settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:settingsController];

    AddFavoriteViewController* favViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"AddFavoriteController"];
    [favViewController setDelegate: self];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:favViewController];
    _addFavoritePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    
    if (![_session isConfigured])
    {
        dispatch_async(dispatch_get_current_queue(), ^{
            [self performSegueWithIdentifier:@"showIdentitySettings" sender:self];
        });
    }
    
    // Customize URL field
    UIImage* backgroundImageOrig = [UIImage imageNamed:@"field_url_background.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(backgroundImageOrig.size.height/2, backgroundImageOrig.size.width/2, backgroundImageOrig.size.height/2, backgroundImageOrig.size.width/2);
    
    UIImage* backgroundImage = nil;
    if ([backgroundImageOrig respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        backgroundImage =  [backgroundImageOrig resizableImageWithCapInsets: insets resizingMode: UIImageResizingModeStretch];
    } else {
        backgroundImage = [backgroundImageOrig resizableImageWithCapInsets: insets];
    }
    _urlText.background = backgroundImage;    
    
    // Create default tab.
    UIWebView* webView = [[UIWebView alloc] init];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.scalesPageToFit = YES;
    _header.tabbedHeaderDelegate = self;
    [_header addTab:@"" active:YES tag:nil contentView: webView];
    
    // Init connection monitor.
    _connectionMonitor = [AppDelegate instance].gatewayConnectionMonitor;
    [_connectionMonitor addDelegate: self];
    
    // Load user agents list.
    if ((_session.username != nil) && (_session.password != nil)) {
        [self checkAgentList];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [_connectionMonitor removeDelegate: self];

    _stopButton = nil;
    _settingsPopoverController = nil;
    _addFavoritePopoverController = nil;
    _session = nil;
    _refreshButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        [_header updateForOrientation: interfaceOrientation];
        return YES;
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    float ratioAspect = _webView.bounds.size.width/_webView.bounds.size.height;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            // Going to Portrait mode
            for (UIScrollView *scroll in [_webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
                }
            }
            break;
        default:
            // Going to Landscape mode
            for (UIScrollView *scroll in [_webView subviews]) { //we get the scrollview
                // Make sure it really is a scroll view and reset the zoom scale.
                if ([scroll respondsToSelector:@selector(setZoomScale:)]){
                    scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
                    scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
                    [scroll setZoomScale:(scroll.zoomScale*ratioAspect) animated:YES];
                }
            }
            break;
    }
}

 
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [_header updateFromOrientation: fromInterfaceOrientation];
    
    if ([_settingsPopoverController isPopoverVisible])
    {
        [_settingsPopoverController dismissPopoverAnimated:NO];
        [self showSettings:self];
        
    }
    else if ([_addFavoritePopoverController isPopoverVisible])
    {
        [_addFavoritePopoverController dismissPopoverAnimated:NO];
        [self showAddFavorite:self];
    }
}

// Creates a User URL string from the Router URL
- (NSString *)userURL:(NSURL *)routerUrl
{
    NSString *path       = [routerUrl path];
    int index;
    BOOL isHttps = NO;
    NSRange userURLStart = [path rangeOfString:@"/http/"];

    if (userURLStart.location == NSNotFound)
    {
        userURLStart = [path rangeOfString:@"/https/"];
        if (userURLStart.location == NSNotFound)
        {
            // if there is no double slash, return the original URL
            return [routerUrl absoluteString];
        }
        isHttps = YES;
        index = userURLStart.location + 7;
    }
    else
    {
        index = userURLStart.location + 6;
    }

    if (index >= [path length])
    {
        // double slash is at the end, return the original URL
        return [routerUrl absoluteString];
    }
    
    NSString *userURL = [NSString stringWithFormat:@"%@://%@", (isHttps ? @"https" : @"http"), [path substringFromIndex:index]];
    
    if ([routerUrl query])
    {
        userURL = [userURL stringByAppendingFormat:@"?%@", [routerUrl query]];
    }
    
    return userURL;
}

// Creates a Router URL from the user URL string
- (NSURL *)routerURL:(NSString *)userUrl error:(NSError **)error
{
    NSURL *connectURL = [_session browserConnectURLWithError:error];
    NSString *routerUrl = userUrl;
    BOOL isHttps = NO;
    
    if (!connectURL)
    {
        return nil;
    }

    // The Router URL always starts as hostname
    if ([userUrl hasPrefix:@"http://"])
    {
        routerUrl = [userUrl substringFromIndex:7];
    }
    else if ([userUrl hasPrefix:@"https://"])
    {
        routerUrl = [userUrl substringFromIndex:8];
        isHttps = YES;
    }

    NSString *query      = nil;
    NSRange   queryRange = [routerUrl rangeOfString:@"?"];
    
    if (queryRange.location != NSNotFound && queryRange.location < [routerUrl length])
    {
        query     = [routerUrl substringFromIndex:queryRange.location];
        routerUrl = [routerUrl substringToIndex:queryRange.location];
    }

    NSURL *finalURL = [connectURL URLByAppendingPathComponent:(isHttps ? @"https" : @"http")];
    finalURL = [finalURL URLByAppendingPathComponent:routerUrl];

    if (query)
    {
        finalURL = [NSURL URLWithString:[[finalURL absoluteString] stringByAppendingString:query]];
    }

    return finalURL;
}

- (void)updateUIWithURL:(NSString *)url
{
    [_back setEnabled:[_webView canGoBack]];
    [_forward setEnabled:[_webView canGoForward]];
    
    if (![url hasPrefix:@"file:///"]) {
        [_urlText setText:url];
    }
    
    if ((_urlText.text.length > 0) && ([_urlText isFirstResponder])) {
        [self setSpinnerTabbed: YES];
    } else {
        [self setSpinnerTabbed: NO];
    }
    
    if (_webView.isLoading) {
        _cancelButton.hidden = NO;
        [self showSpinner];
    } else {
        _cancelButton.hidden = YES;
        [self hideSpinner];
    }
}

- (void)showError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error domain]
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Back"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Spinner support

- (void)switchButton:(UIBarButtonItem *)oldButton withButton:(UIBarButtonItem *)newButton
{
    NSMutableArray *items = [[_toolbar items] mutableCopy];
    NSUInteger oldButtonIndex = [items indexOfObject:oldButton];
    [items replaceObjectAtIndex:oldButtonIndex withObject:newButton];
    [_toolbar setItems:items];
}

- (void)showSpinner
{
    if (![_spinner isAnimating])
    {
        [_spinner startAnimating];
        _refreshButton.hidden = YES;
    }
}

- (void)hideSpinner
{
    if ([_spinner isAnimating])
    {
        [_spinner stopAnimating];
        _refreshButton.hidden = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (void) setSpinnerTabbed:(BOOL)flag {
    CGRect spinnerFrame = _spinner.frame;
    if (flag) {
        spinnerFrame.origin.x = _urlText.frame.origin.x + _urlText.frame.size.width - kSpinnerEditingOffset;
    } else {
        spinnerFrame.origin.x = _urlText.frame.origin.x + _urlText.frame.size.width - kSpinnerDefaultOffset;
    }
    _spinner.frame = spinnerFrame;
    _refreshButton.frame = spinnerFrame;
}

- (IBAction)urlFieldChanged:(id)sender {
    if (sender == _urlText) {
        if (_urlText.text.length > 0) {
            [self setSpinnerTabbed: YES];
        } else {
            [self setSpinnerTabbed: NO];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_urlText.text.length > 0) {
        [self setSpinnerTabbed: YES];
        _cancelButton.hidden = YES;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self setSpinnerTabbed: NO];
    if (_webView.isLoading) {
        _cancelButton.hidden = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != _urlText) return YES;
    if (![[_urlText text] length]) return NO;
    
    [self showSpinner];
    
    [_urlText resignFirstResponder];
    
    _stoppedLoading = NO;
    dispatch_queue_t queue = dispatch_queue_create("Router Communication", NULL);
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSURL *routerURL = [self routerURL:[_urlText text] error:&error];
        
        if (_stoppedLoading)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!routerURL)
            {
                [self hideSpinner];
                if ([[error domain] isEqualToString:RouterCommunicationErrorDomain] && [error code] == InvalidStatusCodeError)
                {
                    NSNumber *statusCode = [[error userInfo] objectForKey:ErrorStatusCodeKey];
                    if ([statusCode integerValue] == 404)
                    {
                        [_session configureAgentId:nil displayName:nil];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Not Available"
                                                                        message:@"Existing connection is not available."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Select a new connection"
                                                              otherButtonTitles:nil];
                        _showingInvalidConnectionAlertView = YES;
                        [alert show];
                        return;
                    }
                }
                [self showError:error];
            }
            else if (!_stoppedLoading)
            {
                [_webView loadRequest:[NSURLRequest requestWithURL:routerURL]];
            }
        });
    });
    
    dispatch_release(queue);
    return YES;
}

#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    if ([url.scheme caseInsensitiveCompare:@"help"] == NSOrderedSame) {
        NSString* urlString = [url.absoluteString stringByReplacingCharactersInRange: NSMakeRange(0, 4) withString: @"http"];
        NSURL* finalUrl = [NSURL URLWithString: urlString];
        [_webView loadRequest:[NSURLRequest requestWithURL: finalUrl]];
        return NO;
    } else if ([url.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame) {
        return YES;
    }
    
    if (wv == _webView) {
        CGRect spinnerFrame = _spinner.frame;
        spinnerFrame.origin.x = _urlText.frame.origin.x + _urlText.frame.size.width - kSpinnerEditingOffset;
        _cancelButton.hidden = NO;
        _cancelButton.frame  = spinnerFrame;
    }
    
    NSLog(@"[%@ %@] URL='%@', navigationType='%d'", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [[request URL] absoluteString], navigationType);

    _stoppedLoading = NO;
    
    if ([@"session-expired" compare:[[request URL] host] options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        // refresh the router session and try the request again
        // Example of the URL http://session-expired/?orig_url=%2Fhttp%2Fwww.nytimes.com%2Fa%2Fb%3Fa%3Db
#ifdef DEBUG
        NSString *origUrl = nil;
        NSArray *pairs = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs)
        {
            NSArray *nameValue = [pair componentsSeparatedByString:@"="];
            if ([[nameValue objectAtIndex:0] isEqualToString:@"orig_url"])
            {
                origUrl = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                    (__bridge CFStringRef)([nameValue objectAtIndex:1]),
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8));
                break;
            }
        }
        if (origUrl)
        {
            if (![origUrl hasPrefix:@"/"])
            {
                origUrl  = [NSString stringWithFormat:@"/%@", origUrl];
            }

            NSLog(@"[%@ %@] Refreshing session with the router, original URL = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), origUrl);
        }
#endif
        _sessionRenewal = YES;
        NSString *topUrl = [_urlText text];

        [_session clearSession];

        dispatch_queue_t queue = dispatch_queue_create("Router Communication", NULL);

        dispatch_async(queue, ^{
            NSError *error = nil;
            NSURL *connectURL = [self routerURL:topUrl error:&error];

            dispatch_async(dispatch_get_main_queue(), ^{
                _sessionRenewal = NO;
                if (!connectURL)
                {
                    [self hideSpinner];
                    [self showError:error];
                }
                else if (!_stoppedLoading)
                {
                    [_webView loadRequest:[NSURLRequest requestWithURL:connectURL]];
                }
            });
        });

        dispatch_release(queue);
        return NO;
    }

    if (navigationType != UIWebViewNavigationTypeOther)
    {
        [_urlText setText:[self userURL:[request URL]]];
    }
    
    [self showSpinner];

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    NSLog(@"[%@ %@] webView URL='%@'", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
          [[[_webView request] URL] absoluteString]);

    NSString* pageTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString* pageUrl = [self userURL:[[_webView request] URL]];
    
    [self updateUIWithURL: pageUrl];
    [self hideSpinner];
    _cancelButton.hidden = YES;
    
    // Add bokmark.
    PageInfoItem* item = [[PageInfoItem alloc]
                          initWithUrl: [NSURL URLWithString: _urlText.text]
                                 name: (pageTitle ? pageTitle : pageUrl)
                                 date: [NSDate date]];
    BookmarkManager* bookmarkManager = [BookmarkManager instance];
    if ((([bookmarkManager.historyItems count] == 0) || ![[bookmarkManager.historyItems objectAtIndex:0] isEqual: item]) && (item.url != nil) && (item.url.absoluteString != nil) && item.url.absoluteString.length > 0) {
        [bookmarkManager addHistoryItem: item];
        [bookmarkManager save];
    }
    
    // Update tab name.
    [_header activeTab].name = (pageTitle ? pageTitle : pageUrl);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"[%@ %@] error = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);

    if (!_stoppedLoading && !_sessionRenewal)
    {
        if ([error code] != -999)
        {
            [self hideSpinner];

            NSString *msg = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Page"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"Back"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - Web view navigation support

- (IBAction)goBack:(id)sender
{
    [_webView goBack];
}

- (IBAction)goForward:(id)sender
{
    [_webView goForward];
}

- (IBAction)refresh:(id)sender
{
    [self textFieldShouldReturn:_urlText];
}

- (IBAction)cancel:(id)sender
{
    [_webView stopLoading];
    [self hideSpinner];
    _cancelButton.hidden = YES;
    _stoppedLoading = YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if (_showingInvalidConnectionAlertView)
    {
        _showingInvalidConnectionAlertView = NO;
        [self performSegueWithIdentifier:@"showAgents" sender:self];
    }
}

#pragma mark - Storyboard segues support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showIdentitySettings"])
    {
        IdentitySettingsViewController *settings = (IdentitySettingsViewController*)[[segue destinationViewController] topViewController];
        [settings setDelegate:self];
        [settings setUsername:[_session username]];
        [settings setPassword:[_session password]];
        [settings setSettings:[_session settings]];
        [settings setCancelDisabled:![_session isConfigured]];
    }
    else if ([[segue identifier] isEqualToString:@"showRouterSettings"])
    {
        RouterSettingsViewController *settings = (RouterSettingsViewController *)[[segue destinationViewController] topViewController];
        [settings setDelegate:self];
        [settings setSettings:[_session settings]];
    } else if ([[segue identifier] isEqualToString:@"showFavorites"]) {
        FavoritesViewController* favorites = (FavoritesViewController*)[[segue destinationViewController] topViewController];
        [favorites setDelegate: self];
    }
    else if ([[segue identifier] isEqualToString:@"showAgents"])
    {
        AgentListViewController *agents = (AgentListViewController*)[[segue destinationViewController] topViewController];
        [agents setDelegate:self];
        [agents setSession:_session];
    }
}

#pragma mark - Settings popover support

- (IBAction)showSettings:(id)sender
{
    NSString* agentName = @"not connected";
    if (_session.displayName) {
        agentName = _session.displayName;
    } else if (_session.agentId) {
        agentName = _session.agentId;
    }
    
    SettingsMenuController* settings = (SettingsMenuController*)_settingsPopoverController.contentViewController;
    settings.connectionLabel.text = [NSString stringWithFormat:@"Current: %@", agentName];
    
    [_settingsPopoverController presentPopoverFromRect:[_settingsPlaceholder bounds]
                                        inView:_settingsPlaceholder
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
}

- (IBAction)showAddFavorite:(id)sender
{
    AddFavoriteViewController *favViewController = (AddFavoriteViewController *)[(UINavigationController*)[_addFavoritePopoverController contentViewController] topViewController];
    [favViewController setBookmarkName:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    [favViewController setBookmarkUrl:_urlText.text];
    [_addFavoritePopoverController presentPopoverFromRect:[_addFavoritePlaceholder bounds]
                                                   inView:_addFavoritePlaceholder
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
}

- (IBAction)showFavorites:(id)sender
{
    [self performSegueWithIdentifier:@"showFavorites" sender:self];
}

- (void)settings:(SettingsMenuController *)settings didSelectItemWithIndex:(NSInteger)index
{
    [_settingsPopoverController dismissPopoverAnimated:YES];
    NSString *segueId = nil;
    switch (index)
    {
        case 0:
            segueId = @"showIdentitySettings";
            break;
        case 1:
            segueId = @"showAgents";
            break;
        case 2:
        {
            [_header removeAllTabs];
            [self updateUIWithURL:@""];
            [_session clearUsernameAndPassword];
            [[BookmarkManager instance] clearHistory];

            UIWebView* webView = [[UIWebView alloc] init];
            webView.autoresizesSubviews = YES;
            webView.scalesPageToFit = YES;
            [_header addTab: @"" active: YES tag: nil contentView: webView];
            
            segueId = @"showIdentitySettings";
            break;
        }
        default:
            break;
    }
    if (segueId)
    {
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

#pragma mark - Identity Settings support

- (void)identitySettings:(IdentitySettingsViewController *)settings DidFinishWithUsername:(NSString *)username password:(NSString*)password;
{
    if (![[settings username] isEqualToString:username] || ![[settings password] isEqualToString:password])
    {
        [_session configureUsername:username password:password];
        [self checkAgentList];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)identitySettingsDidCancel:(IdentitySettingsViewController *)settings
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Router Settings support

- (void)routerSettingsDidCancel:(RouterSettingsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)routerSettings:(RouterSettingsViewController *)controller didFinishWithSettings:(RouterSettings *)settings
{
    [_session setSettings:settings];
    [_connectionMonitor setGatewayUrl:[_session routerAdminURL]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add Favorite Controller support

- (void) viewControllerDidCancel:(AddFavoriteViewController*) viewController {
    [_addFavoritePopoverController dismissPopoverAnimated:YES];
}

- (void) viewControllerDidReturn:(AddFavoriteViewController*) viewController withName:(NSString*) name url:(NSString*) url {
    [_addFavoritePopoverController dismissPopoverAnimated:YES];
    
    PageInfoItem* item = [[PageInfoItem alloc] init];
    item.name = name;
    item.url = [NSURL URLWithString: url];
    item.loadDate = [NSDate date];
    
    BookmarkManager* bookmarkManager = [BookmarkManager instance];
    [bookmarkManager.favoritesItems addObject: item];
    [bookmarkManager saveFavorites];
}

#pragma mark - PageInfoListDelegate

- (void) pageSelected: (PageInfoItem*) page {
    [self dismissModalViewControllerAnimated:YES];
    
    _urlText.text = page.url.absoluteString;
    [self textFieldShouldReturn:_urlText];
}

- (void) viewDismissed {

}

#pragma mark - Gateway Connection Status Listener

// Called when network connection status has changed;
- (void) connectionStatusChanged: (GatewayConnectionStatus) newStatus {
    if (newStatus == GCNoNetwork) {
        [_statusImage setImage: [UIImage imageNamed: @"connection_red.png"]];
    } else if (newStatus == GCNoConnection) {
        [_statusImage setImage: [UIImage imageNamed: @"connection_yellow.png"]];        
    } else if (newStatus == GCConnected) {
        [_statusImage setImage: [UIImage imageNamed: @"connection_green.png"]];
    }
}

#pragma mark - Agent List Support

- (void)agentListDidCancel:(AgentListViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)agentList:(AgentListViewController *)controller didSelectAgentId:(NSString *)agentId withName:(NSString*)name
{
    [[BookmarkManager instance] clearHistory];
    
    // Configure new session.
    [_session configureAgentId: agentId displayName: name];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Tabs support

// Called when tab becomes activated.
- (void) tabActivated: (TabInfo*) tab {
    // Activate tab's web view.
    UIWebView* webView = (UIWebView*)tab.contentView;
    CGRect webViewFrame = webView.frame;
    
    _webView = webView;
    _webView.delegate = self;
    [self updateUIWithURL: [self userURL: _webView.request.URL.absoluteURL]];
    
    // Place web view in content view.
    webViewFrame.origin.x = 0;
    webViewFrame.origin.y = 0;
    webViewFrame.size.width = _contentView.frame.size.width;
    webViewFrame.size.height = _contentView.frame.size.height;
    webView.frame = webViewFrame;
    
    for (UIView* subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    [_contentView addSubview: webView];
}

// Called when user wants to open new tab.
- (void) newTabRequested {
    // Configure web view.
    UIWebView* webView = [[UIWebView alloc] init];
    webView.autoresizesSubviews = YES;
    webView.scalesPageToFit = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    [_header addTab: @"" active:YES tag:nil contentView: webView];
}

- (void) checkAgentList {
    [_activityIndicator startAnimating];
    
    dispatch_queue_t queue = dispatch_queue_create("Router Communication", NULL);
    dispatch_async(queue, ^{
        NSError* error = nil;
        NSArray* agentList = [_session agentListWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
            if ((agentList == nil) || (agentList.count == 0)) {
                [self displayHelpPage];
            }
        });
    });
}

- (void) displayHelpPage {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"no_agents" ofType:@"html"] isDirectory:NO]]];
}

@end
