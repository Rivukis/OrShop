//
//  ShoppingListTableViewController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Store;

@interface ShoppingListTableViewController : UITableViewController

@property (strong, nonatomic) Store *selectedStore;

@end