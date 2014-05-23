//
//  ShoppingItemCell.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *checkOrUncheckButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImage;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemNotesLabel;

@end
