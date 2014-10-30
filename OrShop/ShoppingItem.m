//
//  ShoppingItem.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "ShoppingItem.h"
#import "UIColor+OrShopColors.h"

@interface ShoppingItem () <NSCoding>

@end

@implementation ShoppingItem

- (instancetype)initGenericItemWithStoreName:(NSString *)storeName
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.preferredStore = storeName;
        self.amountNeeded = 1;
        self.tempAtPurchase = 2;
        self.notes = @"";
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.preferredStore = [aDecoder decodeObjectForKey:@"preferredStore"];
        self.amountNeeded = [[aDecoder decodeObjectForKey:@"amountNeeded"] integerValue];
        self.tempAtPurchase = [[aDecoder decodeObjectForKey:@"tempAtPurchase"] integerValue];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        self.isChecked = [[aDecoder decodeObjectForKey:@"isChecked"] boolValue];
        self.checkedOrder = [[aDecoder decodeObjectForKey:@"checkedOrder"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.preferredStore forKey:@"preferredStore"];
    [aCoder encodeObject:@(self.amountNeeded) forKey:@"amountNeeded"];
    [aCoder encodeObject:@(self.tempAtPurchase) forKey:@"tempAtPurchase"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:@(self.isChecked) forKey:@"isChecked"];
    [aCoder encodeObject:@(self.checkedOrder) forKey:@"checkedOrder"];
}

+ (NSArray *)arrayWithOrderedTempAtPurchaseNumbers
{
    return @[@2, @1, @0, @3, @4];
}

- (UIColor *)colorFromTemp
{
    switch (self.tempAtPurchase) {
        case 0:     _colorFromTemp = [UIColor frozenColor];     break;
        case 1:     _colorFromTemp = [UIColor coldColor];       break;
        case 2:     _colorFromTemp = [UIColor roomColor];       break;
        case 3:     _colorFromTemp = [UIColor warmColor];       break;
        case 4:     _colorFromTemp = [UIColor hotColor];        break;
        default:    _colorFromTemp = [UIColor whiteColor];
    }
    
    return _colorFromTemp;
}

- (NSString *)description
{
    return (self.name) ? self.name : @"";
}

@end
