//
//  Item.m
//  OrShop
//
//  Created by Brian Radebaugh on 11/22/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "Item.h"
#import "UIColor+OrShopColors.h"

@implementation Item

//- (instancetype)init {
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
//}

- (instancetype)initGenericItem {
    self = [super init];
    if (self) {
        self.name = @"";
        self.amountNeeded = 1;
        self.temperatureType = ItemTempAmbient;
        self.notes = @"";
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.amountNeeded = [[aDecoder decodeObjectForKey:@"amountNeeded"] integerValue];
        self.temperatureType = [[aDecoder decodeObjectForKey:@"temperatureType"] integerValue];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        self.isChecked = [[aDecoder decodeObjectForKey:@"isChecked"] boolValue];
        self.checkedOrder = [[aDecoder decodeObjectForKey:@"checkedOrder"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:@(self.amountNeeded) forKey:@"amountNeeded"];
    [aCoder encodeObject:@(self.temperatureType) forKey:@"temperatureType"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:@(self.isChecked) forKey:@"isChecked"];
    [aCoder encodeObject:@(self.checkedOrder) forKey:@"checkedOrder"];
}

+ (NSArray *)arrayWithOrderedTemperatureTypes {
    return @[@(ItemTempAmbient),
             @(ItemTempCold),
             @(ItemTempFrozen),
             @(ItemTempWarm),
             @(ItemTempHot)];
}

- (UIColor *)colorFromTemp {
    switch (self.temperatureType) {
        case 0:     _colorFromTemp = [UIColor frozenColor];     break;
        case 1:     _colorFromTemp = [UIColor coldColor];       break;
        case 2:     _colorFromTemp = [UIColor ambientColor];    break;
        case 3:     _colorFromTemp = [UIColor warmColor];       break;
        case 4:     _colorFromTemp = [UIColor hotColor];        break;
        default:    _colorFromTemp = [UIColor whiteColor];
    }
    
    return _colorFromTemp;
}

- (NSString *)description {
    return (self.name) ? self.name : @"no item name";
}

@end
