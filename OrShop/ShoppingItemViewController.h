//
//  ShoppingItemViewController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface ShoppingItemViewController : UIViewController

@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) Item *item;
@property (weak, nonatomic) NSString *segueIdentifier;

@end
