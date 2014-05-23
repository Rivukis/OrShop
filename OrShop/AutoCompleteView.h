//
//  AutoCompleteView.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AutoCompleteViewDelegate <NSObject>

- (void)autoCompleteCellClickedWithTitleString:(NSString *)string;

@end

@interface AutoCompleteView : UIView

@property (nonatomic, unsafe_unretained) id <AutoCompleteViewDelegate> delegate;

- (instancetype)initWithTextField:(UITextField *)textField;
- (void)setHeight;
- (void)reloadDataSourceUsingArray:(NSArray *)array andString:(NSString *)string;

@end
