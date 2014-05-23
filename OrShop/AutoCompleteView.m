//
//  AutoCompleteView.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/29/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "AutoCompleteView.h"

@interface AutoCompleteView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation AutoCompleteView

- (instancetype)initWithTextField:(UITextField *)textField
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"AutoCompleteView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        // Look of View
        self.frame = CGRectMake(textField.frame.origin.x,
                                textField.frame.origin.y + textField.frame.size.height,
                                textField.frame.size.width,
                                0);
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
        
        // Look of Table and Header
        self.tableView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.25];
        self.headerLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:.5];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        
        // Set Delegates
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)reloadDataSourceUsingArray:(NSArray *)array andString:(NSString *)string
{
    self.dataSource = [self arrayWithAutoCompleteItemsFromList:array usingSearchString:string];
    [self setHeight];
    [self.tableView reloadData];
}

- (void)setHeight
{
    int height;
    switch (self.dataSource.count) {
        case 0:     height = 0;     break;      // Show Nothing
        case 1:     height = 42;    break;      // Show Header and 1 Cell
        case 2:     height = 68;    break;      // Show Header and 2 Cells
        case 3:     height = 94;    break;      // Show Header and 3 Cells
        default:    height = 109;               // Show Entire View (header and roughly 3.5 cells)
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}


#pragma mark - UITableView DataSource & Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate autoCompleteCellClickedWithTitleString:cell.textLabel.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.25];
    cell.textLabel.attributedText = self.dataSource[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSArray *)arrayWithAutoCompleteItemsFromList:(NSArray *)fullList usingSearchString:(NSString *)searchString
{
    // Get Array of Lowercase Strings from fullList
    NSMutableArray *lcFullList = [NSMutableArray new];
    for (NSString *string in fullList) {
        [lcFullList addObject:[string lowercaseString]];
    }
    
    // Pull Items from lcFullList Based on searchString
    NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", searchString];
    NSPredicate *containsPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    NSMutableOrderedSet *autoCompleteSet = [NSMutableOrderedSet new];
    
    [autoCompleteSet addObjectsFromArray:[lcFullList filteredArrayUsingPredicate:beginsWithPredicate]];
    [autoCompleteSet addObjectsFromArray:[lcFullList filteredArrayUsingPredicate:containsPredicate]];
    
    // Make Array of Normal Strings Based on Array of Lowercase Strings
    NSMutableArray *autoCompleteArray = [NSMutableArray new];
    for (NSString *foundLCString in autoCompleteSet) {
        for (NSString *string in fullList) {
            if ([[string lowercaseString] isEqualToString:foundLCString]) {
                [autoCompleteArray addObject:string];
                break;
            }
        }
    }
    
    // Change Attributes of Normal Strings in autoCompleteArray Based on searchStrings
    NSMutableArray *attArray = [NSMutableArray new];
    NSString *boldFontName = [[UIFont boldSystemFontOfSize:12] fontName];
    UIColor *normalColor = [UIColor colorWithRed:0.46 green:0.55 blue:0.64 alpha:1];
    UIColor *foundColor = [UIColor blackColor];
    
    for (NSString *autoCompleteString in autoCompleteArray) {
        NSRange searchRange = [[autoCompleteString lowercaseString] rangeOfString:[searchString lowercaseString]];
        if (searchRange.location != NSNotFound) {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:autoCompleteString];
            
            [attString beginEditing];
            [attString addAttribute:NSFontAttributeName // Make searchString Bold
                              value:[UIFont fontWithName:boldFontName size:18.0]
                              range:searchRange];
            [attString addAttribute:NSForegroundColorAttributeName // Set autoCompleteString Color
                              value:normalColor
                              range:[autoCompleteString rangeOfString:autoCompleteString]];
            [attString addAttribute:NSForegroundColorAttributeName // Set searchString Color
                              value:foundColor
                              range:searchRange];
            [attArray addObject:attString];
        }
    }
    
    return [attArray copy];
}

- (NSArray *)dataSource
{
    if (!_dataSource) _dataSource = [NSArray new];
    return _dataSource;
}

@end
