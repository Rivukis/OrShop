//
//  DataSourceController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/20/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "DataSourceController.h"
#import "Store.h"
#import "Item.h"
#import "NSArray+StringHelper.h"

static BOOL const usePlist = YES;
static NSString *const STORES_PLIST = @"stores.plist";
static NSString *const STORE_NAMES_USED_PLIST = @"storeNamesUsed.plist";
static NSString *const ITEM_NAMES_USED_PLIST = @"itemNamesUsed.plist";
static NSString *const ITEMS_SORT_LIST_PLIST = @"itemsSortList.plist";

//TODO: create singleton for data source controller
//TODO: separate archiving part of class into needed ArchiveController

@interface DataSourceController ()

@property (strong, nonatomic) NSArray *stores; // of Store
@property (strong, nonatomic) NSArray *storeNamesUsed; // of NSString
@property (strong, nonatomic) NSArray *itemNamesUsed; // of NSString

@property (strong, nonatomic) NSMutableArray *storeNames;

@end

@implementation DataSourceController

- (NSString *)storeNameForItemName:(NSString *)itemName {
    for (Store *store in self.stores) {
        for (Item *item in store.items) {
            if ([itemName.lowercaseString isEqualToString:item.name.lowercaseString]) {
                return store.name;
            }
        }
    }
    
    return nil;
}

- (NSArray *)arrayOfStoreNames {
    return self.storeNames;
}

// TODO: refactor for new classes
- (void)addToStoreNamesUsed:(NSString *)storeName {
    if (![self.storeNamesUsed containsString:storeName caseSensitive:NO] && ![storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        self.storeNamesUsed = [[self.storeNamesUsed
                                arrayByAddingObject:storeName]
                               sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

// TODO: refactor for new classes
- (void)addToItemNamesUsed:(NSString *)itemName {
    if (![self.itemNamesUsed containsString:itemName caseSensitive:NO] && ![itemName isEqualToString:@""]) {
        self.itemNamesUsed = [[self.itemNamesUsed
                               arrayByAddingObject:itemName]
                              sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

// TODO: refactor for new classes
- (void)removeFromStoreNamesUsed:(NSString *)storeName {
    if ([self.storeNamesUsed containsString:storeName caseSensitive:NO] && ![storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        NSMutableArray *tempArray = [self.storeNamesUsed mutableCopy];
        [tempArray removeString:storeName caseSensitive:NO];
        self.storeNamesUsed = [tempArray copy];
    }
}

// TODO: refactor for new classes
- (void)removeFromItemNamesUsed:(NSString *)itemName {
    if ([self.itemNamesUsed containsString:itemName caseSensitive:NO] && ![itemName isEqualToString:@""]) {
        NSMutableArray *tempArray = [self.itemNamesUsed mutableCopy];
        [tempArray removeString:itemName caseSensitive:NO];
        self.itemNamesUsed = [tempArray copy];
    }
}


- (Store *)storeWithName:(NSString *)storeName {
    for (Store *store in self.stores) {
        if ([store.name isEqualToString:storeName]) {
            return store;
        }
    }
    
    return nil;
}

// TODO: refactor to use Store class not NSString class for parameters ---MAYBE---
- (void)moveItemsFromStoreWithName:(NSString *)fromStoreName toStoreWithName:(NSString *)toStoreName {
    Store *fromStore = [self storeWithName:fromStoreName];
    Store *toStore = [self storeWithName:toStoreName];
    if (!toStore) {
        toStore = [[Store alloc] initWithName:toStoreName items:fromStore.items];
        [self addStore:toStore];
    } else {
        [toStore addShoppingItems:fromStore.items];
    }
    [self removeStore:fromStore];
    [self addToStoreNamesUsed:toStore.name];
}

- (void)moveItem:(Item *)item fromStoreWithName:(NSString *)fromStoreName toStoreWithName:(NSString *)toStoreName {
    Store *fromStore = [self storeWithName:fromStoreName];
    Store *toStore = [self storeWithName:toStoreName];
    if (!toStore) {
        toStore = [[Store alloc] initWithName:toStoreName items:@[item]];
        [self addStore:toStore];
    } else {
        [toStore addShoppingItems:@[item]];
    }
    
    [fromStore removeShoppingItems:@[item]];
    if (fromStore.items.count == 0) [self removeStore:fromStore];
    [self addToStoreNamesUsed:toStore.name];
}

- (void)addStore:(Store *)store {
    self.stores = [self.stores arrayByAddingObject:store];
    [self.storeNames addObject:store.name];
}

- (void)removeStore:(Store *)store {
    NSMutableArray *tempArray = [self.stores mutableCopy];
    [tempArray removeObject:store];
    self.stores = [tempArray copy];
    [self.storeNames removeObject:store.name];
}

// TODO: set up version control for new NoStoreName string
+ (NSString *)stringWithNoStoreName {
//    return @"(no preffered store)";
    return @"Miscellaneous Items";
}


#pragma mark - Saving and Retrieving Methods


// TODO: remove the lists.plist from the file directory using NSFileManager in needed class VersionController
- (void)save {
    NSString *storesPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:STORES_PLIST];
    [NSKeyedArchiver archiveRootObject:self.stores toFile:storesPlistPath];
    
    NSString *storeNamesUsedPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:STORE_NAMES_USED_PLIST];
    [NSKeyedArchiver archiveRootObject:self.storeNamesUsed toFile:storeNamesUsedPlistPath];
    
    NSString *itemNamesUsedPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:ITEM_NAMES_USED_PLIST];
    [NSKeyedArchiver archiveRootObject:self.itemNamesUsed toFile:itemNamesUsedPlistPath];
    
    NSString *itemsSortListPlistPath = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:ITEMS_SORT_LIST_PLIST];
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

+ (BOOL)checkForPlistFileInDocs:(NSString*)fileName {
    NSFileManager *myManager = [NSFileManager defaultManager];
    NSString *pathForPlistInDocs = [[DataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    return [myManager fileExistsAtPath:pathForPlistInDocs];
}

+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


#pragma mark - Plist to Property Constructor Methods


- (NSArray *)storesFromBundleArray:(NSDictionary *)bundleDictionary {
    NSMutableArray *stores = [NSMutableArray new];
    for (NSString *storeName in [bundleDictionary allKeys]) {
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary *plistItem in bundleDictionary[storeName]) {
            Item *item = [[Item alloc] init];
            item.name = plistItem[@"Name"];
            item.amountNeeded = [plistItem[@"AmountNeeded"] intValue];
            item.temperatureType = [plistItem[@"TempAtPurchase"] intValue];
            item.notes = plistItem[@"Notes"];
            
            [items addObject:item];
        }
        Store *store = [[Store alloc] initWithName:storeName items:items];
        [stores addObject:store];
    }
    
    return [stores copy];
}


#pragma mark - Lazy Instantiation


- (NSArray *)stores {
    if (!_stores) {
        _stores = [self objectWithClass:[NSArray class]
                   fromSavedPlistString:STORES_PLIST
                      orFromBundlePlist:@"SampleLists"
               usingConstructorSelector:@selector(storesFromBundleArray:)];
        
        self.storeNames = [NSMutableArray new];
        for (Store *store in _stores) {
            [self.storeNames addObject:store.name];
        }
    }
    
    return _stores;
}

- (NSArray *)storeNamesUsed {
    if (!_storeNamesUsed) {
        _storeNamesUsed = [self objectWithClass:[NSArray class]
                           fromSavedPlistString:STORE_NAMES_USED_PLIST
                              orFromBundlePlist:@"StoreNamesUsed"
                       usingConstructorSelector:nil];
    }
    
    return _storeNamesUsed;
}

- (NSArray *)itemNamesUsed {
    if (!_itemNamesUsed) {
        _itemNamesUsed = [self objectWithClass:[NSArray class]
                          fromSavedPlistString:ITEM_NAMES_USED_PLIST
                             orFromBundlePlist:@"ItemNamesUsed"
                      usingConstructorSelector:nil];
    }
    
    return _itemNamesUsed;
}

- (NSMutableArray *)itemsSortList {
    if (!_itemsSortList) {
        _itemsSortList = [[self objectWithClass:[NSMutableArray class]
                           fromSavedPlistString:ITEMS_SORT_LIST_PLIST
                              orFromBundlePlist:@"ItemsSortList"
                       usingConstructorSelector:nil]
                          mutableCopy];
    }
    
    return _itemsSortList;
}

@end
