//
//  AutoCompleteView.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "AutoCompleteView.h"

@interface AutoCompleteView ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation AutoCompleteView

- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"AutoCompleteView" owner:self options:nil] objectAtIndex:0];
    
    if (self) {
        // View Look
        self.frame = frame;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
        
        // Table and Header Look
        self.tableView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.25];
        self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:.5];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        
        // Geture to Prevent Superviews Getures From Triggering
//        [self.tableView addGestureRecognizer:self.tapGesture];
//        self.tapGesture.enabled = NO;
//        self.tapGesture.
    }
    return self;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) _tapGesture = [UITapGestureRecognizer new];
    return _tapGesture;
}

@end
