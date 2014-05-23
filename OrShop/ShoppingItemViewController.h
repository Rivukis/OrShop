//
//  ShoppingItemViewController.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSourceController.h"
#import "ShoppingItem.h"

@interface ShoppingItemViewController : UIViewController

@property (strong, nonatomic) ShoppingItem *item;
@property (weak, nonatomic) DataSourceController *dataSource;
@property (weak, nonatomic) NSString *segueIdentifier;

@end
