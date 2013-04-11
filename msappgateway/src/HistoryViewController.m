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


#import "HistoryViewController.h"

/*
 * Utility methods.
 */
@interface HistoryViewController (Private)

- (void)clear;
- (void)back;

@end

@implementation HistoryViewController

@synthesize historyTable = _historyTable;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    bookmarkManager = [BookmarkManager instance];
    
    // Custom close button.
    UIButton* backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"history_back.png"] forState:UIControlStateNormal];
    [backButton setTintColor: [UIColor blackColor]];
    [backButton addTarget: self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    [self.navigationItem setLeftBarButtonItem: backItem];

    // Custom close button.
    UIButton* clearButton = [[UIButton alloc] init];
    [clearButton setImage:[UIImage imageNamed:@"clear_history.png"] forState:UIControlStateNormal];
    [clearButton setTintColor: [UIColor blackColor]];
    [clearButton addTarget: self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [clearButton sizeToFit];
    
    UIBarButtonItem* clearItem = [[UIBarButtonItem alloc] initWithCustomView: clearButton];
    [self.navigationItem setRightBarButtonItem: clearItem];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)clear {
    [bookmarkManager clearHistory];
    [bookmarkManager saveHistory];
    [_historyTable reloadData];
    [_historyTable reloadRowsAtIndexPaths: [_historyTable indexPathsForVisibleRows] withRowAnimation: UITableViewRowAnimationFade];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bookmarkManager.historyItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PageInfoItem* item = [bookmarkManager.historyItems objectAtIndex: indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.url.absoluteString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [bookmarkManager removeHistoryItemAtIndex: indexPath.row];
        [bookmarkManager saveHistory];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    PageInfoItem* item = [bookmarkManager.historyItems objectAtIndex: indexPath.row];
    [_delegate pageSelected: item];
}

@end
