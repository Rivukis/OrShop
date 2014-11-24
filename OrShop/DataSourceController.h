//
//  DataSourceController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/20/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class ShoppingItem;
@class Store;
@class Item;

@interface DataSourceController : NSObject

@property (strong, nonatomic) NSArray *stores; // of Store
@property (strong, nonatomic) NSArray *storeNamesUsed; // of NSString
@property (strong, nonatomic) NSArray *itemNamesUsed; // of NSString
@property (strong, nonatomic) NSMutableArray *itemsSortList; // of NSString

- (NSString *)storeNameForItemName:(NSString *)item;

- (void)addToStoreNamesUsed:(NSString *)storeName;
- (void)addToItemNamesUsed:(NSString *)itemName;
- (void)removeFromStoreNamesUsed:(NSString *)storeName;
- (void)removeFromItemNamesUsed:(NSString *)itemName;

- (Store *)storeWithName:(NSString *)storeName;
- (void)moveItemsFromStoreWithName:(NSString *)fromStoreName toStoreWithName:(NSString *)toStoreName;
- (void)moveItem:(Item *)item fromStoreWithName:(NSString *)fromStoreName toStoreWithName:(NSString *)toStoreName;
- (void)addStore:(Store *)store;
- (void)removeStore:(Store *)store;

- (void)save;

+ (NSString *)stringWithNoStoreName;

@end
