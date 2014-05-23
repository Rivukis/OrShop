//
//  ShoppingListTableViewController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSourceController.h"

@interface ShoppingListTableViewController : UITableViewController

@property (weak, nonatomic) DataSourceController *dataSource;
@property (strong, nonatomic) NSString *storeName;

@end