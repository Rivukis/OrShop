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
#import "Store.h"
#import "Item.h"
#import "UIColor+OrShopColors.h"

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
    return self.dataSource.stores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreCell"
                                                            forIndexPath:indexPath];
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:18]];
    cell.textLabel.text = self.storeNames[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentCellIndex = indexPath;
        [self selectCurrentCell];
        [tableView setEditing:NO animated:YES];
        [self.actionMenu show];
    }
}

- (void)selectCurrentCell {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.currentCellIndex];
    cell.backgroundColor = [UIColor highlightedCellColor];
}

- (void)unselectCurrentCell {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.currentCellIndex];
    cell.backgroundColor = [UIColor whiteColor];
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
        [self unselectCurrentCell];
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
    [self unselectCurrentCell];

    // Move All Items in oldStoreList to newStoreList && Save
    if (buttonIndex == 1) {
        NSString *oldStoreName = self.storeNames[self.currentCellIndex.row];
        NSString *newStoreName = [self.moveListAlert textFieldAtIndex:0].text;
        if ([newStoreName isEqualToString:@""]) {
            newStoreName = [DataSourceController stringWithNoStoreName];
        }
        
        // Check If Store Names Are the Same
        if ([newStoreName isEqualToString:oldStoreName]) {
            return;
        }
        
        // Move Items, Save Data, && Reload Table
        [self.dataSource moveItemsFromStoreWithName:oldStoreName toStoreWithName:newStoreName];
        [self.dataSource save];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.storeNames indexOfObject:newStoreName] inSection:0];
        [self.tableView moveRowAtIndexPath:self.currentCellIndex toIndexPath:newIndexPath];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:newIndexPath];
        cell.textLabel.text = newStoreName;
    }
}

- (void)confirmDeletionAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex {
    [self unselectCurrentCell];
    
    // Delete Button Selected
    if (buttonIndex == 1) {
        NSString *storeName = self.storeNames[self.currentCellIndex.row];
        Store *store = [self.dataSource storeWithName:storeName];
        [self.dataSource removeStore:store];
        
        [self.dataSource save];
        [self.tableView deleteRowsAtIndexPaths:@[self.currentCellIndex] withRowAnimation:UITableViewRowAnimationLeft];
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
    return [[self.dataSource arrayOfStoreNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UIAlertView *)actionMenu
{
    if (!_actionMenuAlert) {
        _actionMenuAlert= [[UIAlertView alloc] initWithTitle:@"Actions" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Never Mind" otherButtonTitles:@"Delete List", @"Move Items", nil];
    }
    return _actionMenuAlert;
}

- (UIAlertView *)moveListAlert
{
    if (!_moveListAlert) {
        _moveListAlert = [[UIAlertView alloc] initWithTitle:@"Move All Items" message:@"All items in this list will be moved to the list typed below" delegate:self cancelButtonTitle:@"Never Mind" otherButtonTitles:@"Move Items", nil];
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *storeName = cell.textLabel.text;
        
        ShoppingListTableViewController *destVC = segue.destinationViewController;
        destVC.selectedStore = [self.dataSource storeWithName:storeName];
        destVC.dataSource = self.dataSource;
        
    } else if ([segue.identifier isEqualToString:@"ToNewItem"]) {
        
        //TODO: shouldn't create store and item here / instead do it when user hits save
        
        // Check for "no store" List And Create If Not Found
        NSString *storeName = [DataSourceController stringWithNoStoreName];
        Store *store = [self.dataSource storeWithName:storeName];
        if (!store) {
            store = [[Store alloc] initWithName:storeName items:nil];
            [self.dataSource addStore:store];
        }
        Item *item = [[Item alloc] initGenericItem];
        [store addShoppingItems:@[item]];
        
        ShoppingItemViewController *destVC = segue.destinationViewController;
        destVC.storeName = store.name;
        destVC.item = item;
        destVC.dataSource = self.dataSource;
        destVC.segueIdentifier = segue.identifier;
    }
}

@end
