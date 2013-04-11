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

#import "FavoritesViewController.h"
#import "BookmarkManager.h"
#import "PageInfoItem.h"

typedef enum {
    HistorySection = 0,
    FavoritesSection,
    FavoritesViewSectionsCount
} FavoritesViewSections;

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad {
    bookmarkManager = [BookmarkManager instance];
    
    // Custom close button.
    UIButton* cancelButton = [[UIButton alloc] init];
    [cancelButton setImage:[UIImage imageNamed:@"bookmarks_close.png"] forState:UIControlStateNormal];
    [cancelButton setTintColor: [UIColor blackColor]];
    [cancelButton addTarget: self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    [self.navigationItem setLeftBarButtonItem: cancelItem];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return FavoritesViewSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == HistorySection) {
        return 1;
    } else if (section == FavoritesSection) {
        return [bookmarkManager.favoritesItems count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if (indexPath.section == HistorySection) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else if (indexPath.section == FavoritesSection) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
    }
    
    if (indexPath.section == HistorySection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"History";
    } else if (indexPath.section == FavoritesSection) {
        PageInfoItem* item = [bookmarkManager.favoritesItems objectAtIndex: indexPath.row];
        if (item != nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = item.name;
            cell.detailTextLabel.text = item.url.absoluteString;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == HistorySection) {
        return nil;
    } else if (section == FavoritesSection) {
        return @"Favorites";
    }
    
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == HistorySection) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [bookmarkManager.favoritesItems removeObjectAtIndex: indexPath.row];
        [bookmarkManager saveFavorites];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    if (indexPath.section == HistorySection) {
        [self performSegueWithIdentifier:@"showHistory" sender: self];
    } else {
        if (_delegate != nil) {
            [_delegate pageSelected: [bookmarkManager.favoritesItems objectAtIndex: indexPath.row]];
        }
    }
}

#pragma mark - Dismiss

- (void)cancel {
    if (_delegate != nil) {
        [_delegate viewDismissed];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showHistory"]) {
        HistoryViewController* favorites = (HistoryViewController*)[segue destinationViewController];
        [favorites setDelegate: _delegate];
    }
}

@end
