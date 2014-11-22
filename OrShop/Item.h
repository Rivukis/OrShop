//
//  Item.h
//  OrShop
//
//  Created by Brian Radebaugh on 11/22/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSUInteger, ItemTemp) {
    ItemTempFrozen = 0,
    ItemTempCold,
    ItemTempAmbient,
    ItemTempWarm,
    ItemTempHot
};

@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger amountNeeded;
@property (nonatomic) enum ItemTemp tempAtPurchase;
@property (nonatomic, strong) UIColor *colorFromTemp;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) BOOL isChecked;
@property (nonatomic) NSUInteger checkedOrder;

- (instancetype)initGenericItem;
+ (NSArray *)arrayWithOrderedTempAtPurchaseNumbers;

@end
