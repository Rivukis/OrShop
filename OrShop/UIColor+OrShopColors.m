//
//  UIColor+OrShopColors.m
//  OrShop
//
//  Created by Brian Radebaugh on 10/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "UIColor+OrShopColors.h"

@implementation UIColor (OrShopColors)

+ (UIColor *)frozenColor {
    return [UIColor colorWithRed:0.35 green:0.67 blue:0.89 alpha:1]; // Picton Blue
}

+ (UIColor *)coldColor {
    return [UIColor colorWithRed:0.54 green:0.76 blue:0.95 alpha:0.45]; // Jordy Blue
}

+ (UIColor *)roomColor {
    return [UIColor whiteColor];
}

+ (UIColor *)warmColor {
    return [UIColor colorWithRed:0.94 green:0.28 blue:0.21 alpha:0.3]; // Flamingo
}

+ (UIColor *)hotColor {
    return [UIColor colorWithRed:0.94 green:0.28 blue:0.21 alpha:0.75]; // Flamingo
}

@end