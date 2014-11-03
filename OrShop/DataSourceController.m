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

- (void)addToStoreNamesUsed:(NSString *)storeName
{
    if (![self.storeNamesUsed containsObject:storeName] && ![storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        self.storeNamesUsed = [[self.storeNamesUsed
                                arrayByAddingObject:storeName]
                               sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (void)addToItemNamesUsed:(NSString *)itemName
{
    if (![self.itemNamesUsed containsObject:itemName] && ![itemName isEqualToString:@""]) {
        self.itemNamesUsed = [[self.itemNamesUsed
                               arrayByAddingObject:itemName]
                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (void)removeFromStoreNamesUsed:(NSString *)storeName {
    if ([self.storeNamesUsed containsObject:storeName] && ![storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        NSMutableArray *tempArray = [self.storeNamesUsed mutableCopy];
        [tempArray removeObject:storeName];
        self.storeNamesUsed = [tempArray copy];
    }
}

- (void)removeFromItemNamesUsed:(NSString *)itemName {
    if ([self.itemNamesUsed containsObject:itemName] && ![itemName isEqualToString:@""]) {
        NSMutableArray *tempArray = [self.itemNamesUsed mutableCopy];
        [tempArray removeObject:itemName];
        self.itemNamesUsed = [tempArray copy];
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
    [self addToStoreNamesUsed:toStoreName];
}

+ (NSString *)stringWithNoStoreName
{
    return @"(no preffered store)";
}


#pragma mark - Saving and Retrieving Methods


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

- (id)objectWithClass:(Class)class fromSavedPlistString:(NSString *)savedPlistString orFromBundlePlist:(NSString *)bundlePlistString usingConstructorSelector:(SEL)selector {
    id retrievedObject;
    NSString *plistDocPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:savedPlistString];
    if ([DataSourceController checkForPlistFileInDocs:savedPlistString]) {
        retrievedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:plistDocPath];
    } else {
        if (usePlist) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ShoppingList" ofType:@"plist"];
            NSDictionary *rootDictionary = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
            id subDirectory = rootDictionary[bundlePlistString];
            
            if (selector) {
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:self];
                [invocation setArgument:&(subDirectory) atIndex:2];
                
                [invocation invoke];
                void *tempResults;
                [invocation getReturnValue:&tempResults];
                retrievedObject = (__bridge id)tempResults;
            } else {
                retrievedObject = subDirectory;
            }
        } else {
            retrievedObject = [[class alloc] init];
        }
        [NSKeyedArchiver archiveRootObject:retrievedObject toFile:plistDocPath];
    }
    
    return retrievedObject;
}

+ (BOOL)checkForPlistFileInDocs:(NSString*)fileName
{
    NSFileManager *myManager = [NSFileManager defaultManager];
    NSString *pathForPlistInDocs = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    return [myManager fileExistsAtPath:pathForPlistInDocs];
}

+ (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


#pragma mark - Plist to Property Constructor Methods


- (NSMutableDictionary *)listsFromBundleArray:(NSDictionary *)bundleDictionary {
    NSMutableDictionary *lists = [NSMutableDictionary new];
    for (NSString *storeName in [bundleDictionary allKeys]) {
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *plistItem in bundleDictionary[storeName]) {
            ShoppingItem *item = [ShoppingItem new];
            item.name = plistItem[@"Name"];
            item.amountNeeded = [plistItem[@"AmountNeeded"] intValue];
            item.tempAtPurchase = [plistItem[@"TempAtPurchase"] intValue];
            item.notes = plistItem[@"Notes"];
            item.preferredStore = storeName;
            
            [items addObject:item];
        }
        [lists setObject:items forKey:storeName];
    }
    
    return lists;
}


#pragma mark - Lazy Instantiation


- (NSMutableDictionary *)lists
{
    if (!_lists) {
        _lists = [self objectWithClass:[NSMutableDictionary class]
                  fromSavedPlistString:@"lists.plist"
                     orFromBundlePlist:@"SampleLists"
              usingConstructorSelector:@selector(listsFromBundleArray:)];
    }
    
    return _lists;
}

- (NSArray *)storeNamesUsed
{
    if (!_storeNamesUsed) {
        _storeNamesUsed = [self objectWithClass:[NSArray class]
                           fromSavedPlistString:@"storeNamesUsed.plist"
                              orFromBundlePlist:@"StoreNamesUsed"
                       usingConstructorSelector:nil];
    }
    
    return _storeNamesUsed;
}

- (NSArray *)itemNamesUsed
{
    if (!_itemNamesUsed) {
        _itemNamesUsed = [self objectWithClass:[NSArray class]
                          fromSavedPlistString:@"itemNamesUsed.plist"
                             orFromBundlePlist:@"ItemNamesUsed"
                      usingConstructorSelector:nil];
    }
    
    return _itemNamesUsed;
}

- (NSMutableArray *)itemsSortList
{
    if (!_itemsSortList) {
        _itemsSortList = [self objectWithClass:[NSMutableArray class]
                          fromSavedPlistString:@"itemsSortList.plist"
                             orFromBundlePlist:@"ItemsSortList"
                      usingConstructorSelector:nil];
    }
    
    return _itemsSortList;
}

@end
