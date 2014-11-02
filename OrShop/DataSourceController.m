//
//  DataSourceController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/20/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "DataSourceController.h"
#import "ShoppingItem.h"

@implementation DataSourceController

const BOOL usePlist = YES;

- (void)addToStoreNamesUsedString:(NSString *)storeName
{
    if (![self.storeNamesUsed containsObject:storeName] && ![storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        self.storeNamesUsed = [[self.storeNamesUsed
                                arrayByAddingObject:storeName]
                               sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (void)addToItemNamesUsedString:(NSString *)itemName
{
    if (![self.itemNamesUsed containsObject:itemName]) {
        self.itemNamesUsed = [[self.itemNamesUsed
                               arrayByAddingObject:itemName]
                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (void)moveItemsFromStoreName:(NSString *)fromStoreName toStoreName:(NSString *)toStoreName {
    NSMutableArray *fromStoreList = self.lists[fromStoreName];
    NSMutableArray *toStoreList = self.lists[toStoreName];
    if (!toStoreList) toStoreList = [NSMutableArray new];
    
    for (ShoppingItem *item in fromStoreList) {
        item.preferredStore = toStoreName;
    }
    
    toStoreList = [[toStoreList arrayByAddingObjectsFromArray:fromStoreList] mutableCopy];
    [self.lists setObject:toStoreList forKey:toStoreName];
    [self.lists removeObjectForKey:fromStoreName];
    [self addToStoreNamesUsedString:toStoreName];
}

- (void)save
{
    NSString *listsPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"lists.plist"];
    [NSKeyedArchiver archiveRootObject:self.lists toFile:listsPlistPath];
    
    NSString *storeNamesUsedPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"storeNamesUsed.plist"];
    [NSKeyedArchiver archiveRootObject:self.storeNamesUsed toFile:storeNamesUsedPlistPath];
    
    NSString *itemNamesUsedPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"itemNamesUsed.plist"];
    [NSKeyedArchiver archiveRootObject:self.itemNamesUsed toFile:itemNamesUsedPlistPath];
    
    NSString *itemsSortListPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"itemsSortList.plist"];
    [NSKeyedArchiver archiveRootObject:self.itemsSortList toFile:itemsSortListPlistPath];
}

+ (BOOL)checkForPlistFileInDocs:(NSString*)fileName
{
    NSFileManager *myManager = [NSFileManager defaultManager];
//    NSString *pathForPlistInBundle = [[NSBundle mainBundle] pathForResource:@"people" ofType:@"plist"];
    NSString *pathForPlistInDocs = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    return [myManager fileExistsAtPath:pathForPlistInDocs];
}

+ (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)stringWithNoStoreName
{
    return @"(no preffered store)";
}


#pragma mark - Lazy Instantiation


- (NSMutableDictionary *)lists
{
    if (!_lists) {
        
        NSString *plistDocPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"lists.plist"];
        
        if ([DataSourceController checkForPlistFileInDocs:@"lists.plist"]) {
            // Load from Archived Plist
            _lists = [NSKeyedUnarchiver unarchiveObjectWithFile:plistDocPath];
        } else {
            _lists = [NSMutableDictionary new];
            if (usePlist) {
                // Load from Manually Created Plist
                NSString *pathBundle = [[NSBundle mainBundle] pathForResource:@"ShoppingList" ofType:@"plist"];
                NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:pathBundle];
                
                for (NSString *storeName in [rootDictionary[@"SampleLists"] allKeys]) {
                    NSMutableArray *items = [NSMutableArray new];
                    
                    for (NSDictionary *plistItem in rootDictionary[@"SampleLists"][storeName]) {
                        ShoppingItem *item = [ShoppingItem new];
                        item.name = plistItem[@"Name"];
                        item.amountNeeded = [plistItem[@"AmountNeeded"] intValue];
                        item.tempAtPurchase = [plistItem[@"TempAtPurchase"] intValue];
                        item.notes = plistItem[@"Notes"];
                        item.preferredStore = storeName;
                        
                        [items addObject:item];
                    }
                    [_lists setObject:items forKey:storeName];
                }
            }
            [NSKeyedArchiver archiveRootObject:_lists toFile:plistDocPath];
        }
    }
    
    return _lists;
}

- (NSArray *)storeNamesUsed
{
    if (!_storeNamesUsed) {
        
        NSString *plistDocPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"storeNamesUsed.plist"];
        
        if ([DataSourceController checkForPlistFileInDocs:@"storeNamesUsed.plist"]) {
            // Load from Archived Plist
            _storeNamesUsed = [NSKeyedUnarchiver unarchiveObjectWithFile:plistDocPath];
        } else {
            _storeNamesUsed = [NSArray new];
            if (usePlist) {
                // Load from Manually Created Plist
                NSString *pathBundle = [[NSBundle mainBundle] pathForResource:@"ShoppingList" ofType:@"plist"];
                NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:pathBundle];
                NSMutableArray *tempArray = [NSMutableArray new];
                
                for (NSString *storeName in rootDictionary[@"StoreNamesUsed"])
                    [tempArray addObject:storeName];
                
                _storeNamesUsed = [tempArray copy];
            }
            [NSKeyedArchiver archiveRootObject:_storeNamesUsed toFile:plistDocPath];
        }
    }
    return _storeNamesUsed;
}

- (NSArray *)itemNamesUsed
{
    if (!_itemNamesUsed) {
        NSString *plistDocPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"itemNamesUsed.plist"];
        
        if ([DataSourceController checkForPlistFileInDocs:@"itemNamesUsed.plist"]) {
            // Load from Archived Plist
            _itemNamesUsed = [NSKeyedUnarchiver unarchiveObjectWithFile:plistDocPath];
        } else {
            _itemNamesUsed = [NSArray new];
            if (usePlist) {
                // Load from Manually Created Plist
                NSString *pathBundle = [[NSBundle mainBundle] pathForResource:@"ShoppingList" ofType:@"plist"];
                NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:pathBundle];
                NSMutableArray *tempArray = [NSMutableArray new];
                
                for (NSString *itemName in rootDictionary[@"ItemNamesUsed"])
                    [tempArray addObject:itemName];
                
                _itemNamesUsed = [tempArray copy];
            }
            [NSKeyedArchiver archiveRootObject:_itemNamesUsed toFile:plistDocPath];
        }
    }
    
    return _itemNamesUsed;
}

- (NSMutableArray *)itemsSortList
{
    if (!_itemsSortList) {
        _itemsSortList = [NSMutableArray new];
        NSString *plistDocPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:@"itemsSortList.plist"];
        
        if ([DataSourceController checkForPlistFileInDocs:@"itemsSortList.plist"]) {
            // Load from Archived Plist
            _itemsSortList = [NSKeyedUnarchiver unarchiveObjectWithFile:plistDocPath];
        } else {
            _itemsSortList = [NSMutableArray new];
            if (usePlist) {
                // Load from Manually Created Plist
                NSString *pathBundle = [[NSBundle mainBundle] pathForResource:@"ShoppingList"
                                                                       ofType:@"plist"];
                NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:pathBundle];
                
                for (NSString *itemName in rootDictionary[@"ItemsSortList"])
                    [_itemsSortList addObject:itemName];
            }
            [NSKeyedArchiver archiveRootObject:_itemsSortList toFile:plistDocPath];
        }
    }
    
    return _itemsSortList;
}

@end
