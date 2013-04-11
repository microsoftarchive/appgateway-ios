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

#import <Foundation/Foundation.h>
#import "PageInfoItem.h"
#import "RouterSession.h"

/*
 * Provides access to the favorites & history.
 */
@interface BookmarkManager : NSObject {
    NSMutableArray* historyItems;
    NSMutableArray* favoritesItems;
}

@property (nonatomic, readonly, getter=getHistory) NSArray* historyItems;
@property (nonatomic, strong) NSMutableArray* favoritesItems;

// Returns an instance of BookmarkManager.
+ (BookmarkManager*) instance;

// Saves changes made to the bookmarks.
- (void) save;

// Discards all changes made to the bookmarks since the last save.
- (void) reload;

// Saves history to file.
- (void) saveHistory;

// Reloads history from file.
- (NSArray*) reloadHistory;

// Saves favorites to file.
- (void) saveFavorites;

// Reloads favorites from file.
- (NSMutableArray*) reloadFavorites;

// Returns YES if there is saved page item similar to the given item.
- (BOOL) hasFavoriteItem: (PageInfoItem*) item;

// Returns YES if there is a favorite item with the given URL saved in favorites.
- (BOOL) hasFavoriteItemWithUrl: (NSURL*) url;

// Clears history stack.
- (void) clearHistory;

// Adds new page item into history stack.
- (void) addHistoryItem:(PageInfoItem*)item;

// Removes page item from the history stack.
- (void) removeHistoryItem:(PageInfoItem*)item;

// Removes page item at the given index from the history stack.
- (void) removeHistoryItemAtIndex:(NSInteger)index;

@end
