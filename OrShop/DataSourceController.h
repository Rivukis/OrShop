//
//  DataSourceController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/20/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSourceController : NSObject

//@property (strong, nonatomic) NSMutableDictionary *needLists; // of NSMutableArray
//@property (strong, nonatomic) NSMutableDictionary *haveLists; // of NSMutableArray

@property (strong, nonatomic) NSMutableDictionary *lists; // of NSMutableArray
@property (strong, nonatomic) NSArray *storeNamesUsed; // of NSString
@property (strong, nonatomic) NSArray *itemNamesUsed; // of NSString
@property (strong, nonatomic) NSMutableArray *itemsSortList; // of NSString

- (void)save;
- (void)addToStoreNamesUsedString:(NSString *)storeName;
- (void)addToItemNamesUsedString:(NSString *)itemName;
- (void)moveItemsFromStoreName:(NSString *)fromStoreName toStoreName:(NSString *)toStoreName;

+ (NSString *)stringWithNoStoreName;

@end
