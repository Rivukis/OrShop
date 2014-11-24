//
//  Store.h
//  OrShop
//
//  Created by Brian Radebaugh on 11/22/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface Store : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSArray *items; // of Item

- (instancetype)initWithName:(NSString *)name items:(NSArray *)items;

- (void)addShoppingItems:(NSArray *)items;
- (void)removeShoppingItems:(NSArray *)items;
- (void)replaceShoppingItems:(NSArray *)items;

@end
