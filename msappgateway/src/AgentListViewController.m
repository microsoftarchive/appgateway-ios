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

#import "AgentListViewController.h"

@interface AgentListViewController ()

@end

@implementation AgentListViewController
{
    NSArray *_agents;
}

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
    [_spinner startAnimating];
    [_spinner setHidden:NO];
    
    dispatch_queue_t queue = dispatch_queue_create("Router Communication", NULL);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        _agents = [_session agentListWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinner setHidden:YES];
            if (!_agents)
            {
                NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithCapacity:1];
                [entry setObject:[error localizedDescription] forKey:@"display_name"];
                NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:1];
                [a addObject:entry];
                _agents = a;
                [[self tableView] setAllowsSelection:NO];
            }
            [[self tableView] reloadData];
        });
    });
    
    dispatch_release(queue);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate {
   return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_agents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AgentNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary* agentInfo = [_agents objectAtIndex:[indexPath row]];
    NSString* agentDisplayName = [agentInfo objectForKey:@"display_name"];
    NSString* agentID = [agentInfo objectForKey:@"agent_id"];
    
    if ((agentDisplayName == nil) || (agentDisplayName.length == 0)) {
        agentDisplayName = [agentID copy];
    }
    
    if ([agentID caseInsensitiveCompare: _session.agentId] == NSOrderedSame) {
        agentDisplayName = [NSString stringWithFormat: @"[CURRENTLY IN USE] %@", agentDisplayName];
    }
    
    [[cell textLabel] setText: agentDisplayName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *agentId = [[_agents objectAtIndex:[indexPath row]] objectForKey:@"agent_id"];
    NSLog(@"[%@ %@] Switching to agent ID %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), agentId);
    [_delegate agentList:self didSelectAgentId:agentId withName: [[_agents objectAtIndex:[indexPath row]] objectForKey:@"display_name"]];
}

- (IBAction)cancel:(id)sender
{
    [_delegate agentListDidCancel:self];
}

@end
