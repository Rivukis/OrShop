//
//  ShoppingItem.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShoppingItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger amountNeeded;
@property (nonatomic, strong) NSString *preferredStore;
@property (nonatomic) NSUInteger tempAtPurchase;
@property (nonatomic, strong) UIColor *colorFromTemp;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) BOOL isChecked;
@property (nonatomic) NSUInteger checkedOrder;

- (instancetype)initGenericItemWithStoreName:(NSString *)storeName;
+ (NSArray *)arrayWithOrderedTempAtPurchaseNumbers;

@end
