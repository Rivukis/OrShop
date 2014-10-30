//
//  StoreTableViewController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "StoreTableViewController.h"
#import "ShoppingListTableViewController.h"
#import "ShoppingItemViewController.h"
#import "DataSourceController.h"

@interface StoreTableViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) DataSourceController *dataSource;
@property (strong, nonatomic) NSArray *storeNames;

@property (strong, nonatomic) UIAlertView *actionMenuAlert;
@property (strong, nonatomic) UIAlertView *moveListAlert;
@property (strong, nonatomic) UIAlertView *confirmDeleteAlert;
@property (strong, nonatomic) NSIndexPath *currentCellIndex;

@end

@implementation StoreTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate && DataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreCell"
                                                            forIndexPath:indexPath];
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:18]];
    cell.textLabel.text = self.storeNames[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentCellIndex = indexPath;
        [self.actionMenu show];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Actions";
}

// TODO: This to stop the resizing of cells when cell is selected. Find real fix.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}


#pragma mark - UIAlertView Delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.actionMenuAlert]) {
        [self actionMenuAlertViewClickedButtonAtIndex:buttonIndex];
    } else if ([alertView isEqual:self.moveListAlert]) {
        [self MoveListAlertViewClickedButtonAtIndex:buttonIndex];
    } else if ([alertView isEqual:self.confirmDeleteAlert]) {
        [self confirmDeletionAlertViewClickedButtonAtIndex:buttonIndex];
    }
}

- (void)actionMenuAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex {
    // Never Mind Button Selected
    if (buttonIndex == 0) {
        [self.tableView setEditing:NO animated:YES];
    }
    // Delete Button Selected
    else if (buttonIndex == 1) {
        [self.confirmDeleteAlert show];
    }
    // Move Button Selected
    else if (buttonIndex == 2) {
        [[self.moveListAlert textFieldAtIndex:0] setText:@""];
        [[self.moveListAlert textFieldAtIndex:0] setPlaceholder:self.storeNames[self.currentCellIndex.row]];
        [self.moveListAlert show];
    }
}

- (void)MoveListAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex {
    // Never Mind Button Selected
    if (buttonIndex == 0) {
        [self.tableView setEditing:NO animated:YES];
    }
    // Move All Items in oldStoreList to newStoreList && Save
    else if (buttonIndex == 1) {
        NSString *oldStoreName = self.storeNames[self.currentCellIndex.row];
//        NSMutableArray *oldStoreList = self.dataSource.lists[oldStoreName];
        NSString *newStoreName = [self.moveListAlert textFieldAtIndex:0].text;
        if ([newStoreName isEqualToString:@""]) newStoreName = [DataSourceController stringWithNoStoreName];
        
        // Check If Store Names Are the Same
        if ([newStoreName isEqualToString:oldStoreName]) {
            [self.tableView setEditing:NO animated:YES];
            return;
        }
        // Create || Access newStoreList
//        NSMutableArray *newStoreList = self.dataSource.lists[newStoreName];
//        if (!newStoreList) newStoreList = [NSMutableArray new];
        
        // Move Items, Save Data, && Reload Table
        [self.dataSource moveItemsFromStoreName:oldStoreName toStoreName:newStoreName];
        
//        newStoreList = [[newStoreList arrayByAddingObjectsFromArray:oldStoreList] mutableCopy];
//        [self.dataSource.lists setObject:newStoreList forKey:newStoreName];
//        [self.dataSource.lists removeObjectForKey:oldStoreName];
//        [self.dataSource addToStoreNamesUsedString:newStoreName];
        [self.dataSource save];
        [self.tableView reloadData];
    }
}

- (void)confirmDeletionAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex {
    // Keep Button Selected
    if (buttonIndex == 0) {
        [self.tableView setEditing:NO animated:YES];
    }
    // Delete Button Selected
    else if (buttonIndex == 1) {
        NSString *storeName = self.storeNames[self.currentCellIndex.row];
        [self.dataSource.lists removeObjectForKey:storeName];
        [self.dataSource save];
        [self.tableView setEditing:NO animated:YES];
        [self.tableView deleteRowsAtIndexPaths:@[self.currentCellIndex] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}


#pragma mark - Lazy Instantiation


- (DataSourceController *)dataSource
{
    if (!_dataSource) _dataSource = [DataSourceController new];
    return _dataSource;
}

- (NSArray *)storeNames
{
    return [[self.dataSource.lists allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UIAlertView *)actionMenu
{
    if (!_actionMenuAlert) {
        _actionMenuAlert= [[UIAlertView alloc] initWithTitle:@"Actions" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Never Mind" otherButtonTitles:@"Delete", @"Move", nil];
    }
    return _actionMenuAlert;
}

- (UIAlertView *)moveListAlert
{
    if (!_moveListAlert) {
        _moveListAlert = [[UIAlertView alloc] initWithTitle:@"Move All Items" message:@"All items in this list will be moved to the list typed below" delegate:self cancelButtonTitle:@"Never Mind" otherButtonTitles:@"Move", nil];
        _moveListAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [_moveListAlert textFieldAtIndex:0];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    return _moveListAlert;
}

- (UIAlertView *)confirmDeleteAlert
{
    if (!_confirmDeleteAlert) _confirmDeleteAlert= [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                                              message:@"Deleting this list will also delete all items in this list."
                                                                             delegate:self
                                                                    cancelButtonTitle:@"Never Mind"
                                                                    otherButtonTitles:@"Delete!", nil];
    return _confirmDeleteAlert;
}


#pragma mark - Navigation Methods


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToShoppingList"]) {
        ShoppingListTableViewController *destVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *storeName = cell.textLabel.text;
        
        destVC.storeName = storeName;
        destVC.dataSource = self.dataSource;
        
    } else if ([segue.identifier isEqualToString:@"ToNewItem"]) {
        
        // Check for "no store" List And Create If Not Found
        NSString *storeName = [DataSourceController stringWithNoStoreName];
        NSMutableArray *storeList = self.dataSource.lists[storeName];
        if (storeList == NULL) {
            storeList = [NSMutableArray new];
            [self.dataSource.lists setObject:storeList forKey:storeName];
        }
        ShoppingItem *item = [[ShoppingItem alloc] initGenericItemWithStoreName:storeName];
        [storeList addObject:item];
        
        ShoppingItemViewController *destVC = segue.destinationViewController;
        destVC.item = item;
        destVC.dataSource = self.dataSource;
        destVC.segueIdentifier = segue.identifier;
    }
}

@end
