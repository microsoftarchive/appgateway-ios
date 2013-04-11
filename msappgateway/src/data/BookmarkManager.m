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

#import "BookmarkManager.h"

#define kHistoryFilePath   @"History.plist"
#define kFavoritesFilePath @"Favorites.plist"
#define kHistoryLength     20

static BookmarkManager* instance;

/*
 * Helper methods.
 */
@interface BookmarkManager (Private)

// Sort history array.
- (void) sortHistoryItems;

@end


@implementation BookmarkManager

@synthesize favoritesItems;
@synthesize historyItems;

// Returns an instance of BookmarkManager.
+ (BookmarkManager*) instance {
    if (instance == nil) {
        instance = [[BookmarkManager alloc] init];
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        [self reloadHistory];
        [self reloadFavorites];
    }
    return self;
}

// Saves history to file.
- (void) saveHistory {
    // Base directory.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = [paths objectAtIndex:0];
    
    BOOL result = NO;
    NSError* error;

    // Saving history.
    NSString* historyPath = [basePath stringByAppendingPathComponent: kHistoryFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: historyPath]) {
        [[NSFileManager defaultManager] removeItemAtPath: historyPath error: &error];
    }
    
    NSData* historyData = [NSKeyedArchiver archivedDataWithRootObject: historyItems];
    result = [historyData writeToFile: historyPath atomically: YES];
}

// Reloads history from file.
- (NSArray*) reloadHistory {
    // Base directory.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = [paths objectAtIndex:0];

    // Discarding history.
    NSString* historyPath = [basePath stringByAppendingPathComponent: kHistoryFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: historyPath]) {
        historyItems = [NSKeyedUnarchiver unarchiveObjectWithFile: historyPath];
    }
    
    if (historyItems == nil) {
        historyItems = [[NSMutableArray alloc] init];
    }
    
    return self.historyItems;
}

// Saves favorites to file.
- (void) saveFavorites {
    // Base directory.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = [paths objectAtIndex:0];
    
    BOOL result = NO;
    NSError* error;
    
    // Saving favorites.
    NSString* favoritesPath = [basePath stringByAppendingPathComponent: kFavoritesFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: favoritesPath]) {
        [[NSFileManager defaultManager] removeItemAtPath: favoritesPath error: &error];
    }
    
    NSData* favoritesData = [NSKeyedArchiver archivedDataWithRootObject: favoritesItems];
    result = [favoritesData writeToFile: favoritesPath atomically: YES];
}

// Reloads favorites from file.
- (NSMutableArray*) reloadFavorites {
    // Base directory.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = [paths objectAtIndex:0];

    // Discarding favorites.
    NSString* favoritesPath = [basePath stringByAppendingPathComponent: kFavoritesFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: favoritesPath]) {
        favoritesItems = [NSKeyedUnarchiver unarchiveObjectWithFile: favoritesPath];
    }
    
    if (favoritesItems == nil) {
        favoritesItems = [[NSMutableArray alloc] init];
    }
    
    return favoritesItems;
}

// Returns YES if there is saved page item similar to the given item.
- (BOOL) hasFavoriteItem: (PageInfoItem*) item {
    for (PageInfoItem* savedItem in favoritesItems) {
        if ([savedItem isEqual:item]) {
            return YES;
        }
    }
    
    return NO;
}

// Returns YES if there is a favorite item with the given URL saved in favorites.
- (BOOL) hasFavoriteItemWithUrl: (NSURL*) url {
    for (PageInfoItem* savedItem in favoritesItems) {
        if ([savedItem.url.absoluteString caseInsensitiveCompare: url.absoluteString] == NSOrderedSame) {
            return YES;
        }
    }
    
    return NO;
}

// Saves changes made to the bookmarks.
- (void) save {
    [self saveHistory];
    [self saveFavorites];

}

// Discards all changes made to the bookmarks since the last save.
- (void) reload {
    [self reloadHistory];
    [self reloadFavorites];
}

- (NSArray*)getHistory {
    return [NSArray arrayWithArray: historyItems];
}

// Adds new page item into history stack.
- (void) addHistoryItem:(PageInfoItem*)item {
    if ([historyItems count] >= kHistoryLength) {
        [historyItems removeObjectAtIndex: 0];
    }
    [historyItems addObject: item];
    
    [self sortHistoryItems];
}

// Removes page item from the history stack.
- (void) removeHistoryItem:(PageInfoItem*)item {
    if ([historyItems indexOfObject: item] != NSNotFound) {
        [historyItems removeObject: item];
    }
    
    [self sortHistoryItems];
}

// Removes page item at the given index from the history stack.
- (void) removeHistoryItemAtIndex:(NSInteger)index {
    if ([historyItems count] > index) {
        [historyItems removeObjectAtIndex: index];
    }

    [self sortHistoryItems];
}

// Clears history stack.
- (void) clearHistory {
    [historyItems removeAllObjects];
}

// Sort history array.
- (void) sortHistoryItems {
    NSArray *sortedArray;
    sortedArray = [historyItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(PageInfoItem*)a loadDate];
        NSDate *second = [(PageInfoItem*)b loadDate];
        return [second compare: first];
    }];
    
    historyItems = [NSMutableArray arrayWithArray: sortedArray];
}

@end
