//
//  ShoppingListTableViewController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "ShoppingListTableViewController.h"
#import "ShoppingItemCell.h"
#import "ShoppingItemViewController.h"
#import "DataSourceController.h"
#import "Store.h"
#import "Item.h"
#import "UIColor+OrShopColors.h"

@interface ShoppingListTableViewController () <UITableViewDelegate>

@property (strong, nonatomic) NSArray *rightBarButtons;
@property (strong, nonatomic) UIRefreshControl *pullRefreshControl;
@property (strong, nonatomic) UIAlertView *confirmDeleteAlert;
@property (strong, nonatomic) NSIndexPath *currentCellIndex;

@property (strong, nonatomic) NSMutableArray *needItems;
@property (strong, nonatomic) NSMutableArray *haveItems;

@end

@implementation ShoppingListTableViewController

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
    self.title = self.selectedStore.name;
    [self.navigationItem setRightBarButtonItems:self.rightBarButtons];
    self.refreshControl = self.pullRefreshControl;
    [self reloadNeedAndHaveArrays];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshTableView];
    if (self.needItems.count == 0 && self.haveItems.count == 0) [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadNeedAndHaveArrays
{
    self.needItems = nil;
    self.haveItems = nil;
    
    for (Item *item in self.selectedStore.items) {
        if (item.isChecked) {
            [self.haveItems addObject:item];
        } else {
            [self.needItems addObject:item];
        }
    }
    
    self.needItems = [self sortUsingDataSourceOnMutableArray:self.needItems];
    
    NSSortDescriptor *haveSorter = [[NSSortDescriptor alloc] initWithKey:@"checkedOrder" ascending:YES];
    [self.haveItems sortUsingDescriptors:@[haveSorter]];
    
    Item *lastHaveItem = self.haveItems.lastObject;
    if (lastHaveItem.checkedOrder != self.haveItems.count) {
        for (Item *haveItem in self.haveItems) {
            haveItem.checkedOrder = [self.haveItems indexOfObject:haveItem];
        }
    }
}

- (void)refreshTableView
{
    [self reloadNeedAndHaveArrays];
    [self.tableView reloadData];
    if (self.refreshControl.refreshing) [self.refreshControl endRefreshing];
}

- (void)doneShopping
{
    [self refreshTableView];
    [self saveChangesToDataSourceSortListUsingMutableArray:self.haveItems];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewItem
{
    [self performSegueWithIdentifier:@"ToNewItem" sender:nil];
}


#pragma mark - Sorting Methods


- (NSMutableArray *)sortUsingDataSourceOnMutableArray:(NSMutableArray *)arrayToSort
{
    // Sort Based on Data Source List
    NSMutableArray *sortedArray = [NSMutableArray new];
    
    // - Add Known Items To Sorted Array
    for (NSString *itemName in self.dataSource.itemsSortList) {
        for (Item *item in arrayToSort) {
            if ([itemName isEqualToString:item.name]) {
                [sortedArray addObject:item];
            }
        }
    }
    
    // - Add Unknown Items To Sorted Array
    NSMutableArray *unKnownItems = [NSMutableArray new];
    for (Item *item in arrayToSort) {
        if (![sortedArray containsObject:item]) [unKnownItems addObject:item];
    }
    sortedArray = [[unKnownItems arrayByAddingObjectsFromArray:sortedArray] mutableCopy];
    
    // Re-sort Based on Item Temp At Purchase
    arrayToSort = [sortedArray mutableCopy];
    sortedArray = [NSMutableArray new];
    NSArray *tempAtPurchaseOrder = [Item arrayWithOrderedTemperatureTypes];
    
    // - Add Known Temps To Sorted Array
    for (int i = 0; i < tempAtPurchaseOrder.count; i++) {
        for (Item *item in arrayToSort) {
            if (item.temperatureType == [tempAtPurchaseOrder[i] integerValue]) {
                [sortedArray addObject:item];
            }
        }
    }
    
    // - Add Unknown Temps To Sorted Array
    for (Item *item in arrayToSort) {
        if (![sortedArray containsObject:item]) [sortedArray addObject:item];
    }
    
    arrayToSort = [NSMutableArray new];
    
    return sortedArray;
}

- (void)saveChangesToDataSourceSortListUsingMutableArray:(NSMutableArray *)inputArray
{
    NSMutableArray *sortList = self.dataSource.itemsSortList;
    sortList = (sortList) ? sortList : [NSMutableArray new];
    inputArray = (inputArray) ? inputArray : [NSMutableArray new];
    
    NSMutableArray *inputArrayIndexesOfItemsAlsoInSortList;
    
    NSInteger currentInputArrayItemIndex;
    NSInteger belowInputArrayItemIndex;         // Start Below Lowest Index
    NSInteger aboveInputArrayItemIndex;         // Start Above Highest Index
    
    NSInteger currentDataSourceItemIndex;
    NSInteger belowDataSourceItemIndex;         // Start Below Lowest Index
    NSInteger aboveDataSourceItemIndex;         // Start Above Highest Index
    
    NSInteger lastItemSortListIndex = -1;
    NSInteger placeToAddIndex;
    NSInteger moveOptionTracker;
    
    // Make and Load inputArrayIndexesOfItemsAlsoInSortList
    inputArrayIndexesOfItemsAlsoInSortList = [NSMutableArray new];
    for (Item *item in inputArray) {
        if ([sortList containsObject:item.name]) {
            [inputArrayIndexesOfItemsAlsoInSortList addObject:@([inputArray indexOfObject:item])];
        }
    }
    
    // Move Items In sortList Based On Order in inputArray
    for (Item *item in inputArray) {
        currentInputArrayItemIndex = [inputArray indexOfObject:item];
        belowInputArrayItemIndex = -1;
        aboveInputArrayItemIndex = inputArray.count;
        
        // Get Below, Current, & Above inputArray Indexes Of Items In Both Lists (inputArray && sortList)
        if (inputArrayIndexesOfItemsAlsoInSortList.count > 0) {
            if ([inputArrayIndexesOfItemsAlsoInSortList containsObject:@(currentInputArrayItemIndex)]) {
                // Current Item is in sortList
                NSInteger currentIndexArrayIndex = [inputArrayIndexesOfItemsAlsoInSortList indexOfObject:@(currentInputArrayItemIndex)];
                if (currentIndexArrayIndex != 0) {
                    belowInputArrayItemIndex = [inputArrayIndexesOfItemsAlsoInSortList[currentIndexArrayIndex - 1] integerValue];
                }
                if (currentIndexArrayIndex != inputArrayIndexesOfItemsAlsoInSortList.count - 1) {
                    aboveInputArrayItemIndex = [inputArrayIndexesOfItemsAlsoInSortList[currentIndexArrayIndex + 1] integerValue];
                }
            } else {
                // Current Item is Not in sortList
                BOOL isSearching = YES;
                NSInteger searchUpperBound = inputArrayIndexesOfItemsAlsoInSortList.count - 1;
                NSInteger searchLowerBound = 0;
                NSInteger searchLocation;
                NSInteger aboveNumber;
                NSInteger belowNumber;
                
                // Only one item in inputArrayIndexesOfItemsAlsoInSortList and Is Below Current Item Index
                if (inputArrayIndexesOfItemsAlsoInSortList.count == 1 &&
                    currentInputArrayItemIndex > [inputArrayIndexesOfItemsAlsoInSortList.firstObject integerValue]) {
                    isSearching = NO;
                }
                
                while (isSearching) {
                    searchLocation = ceilf(((searchUpperBound - searchLowerBound) / 2.0) + searchLowerBound);
                    if (searchLowerBound == searchUpperBound && searchLocation == 0) {
                        // searchLocation Out of Lower Bounds
                        aboveInputArrayItemIndex = [[inputArrayIndexesOfItemsAlsoInSortList firstObject] integerValue];
                        belowInputArrayItemIndex = -1;
                        isSearching = NO;
                    } else if (searchLowerBound == searchUpperBound && searchLocation == inputArrayIndexesOfItemsAlsoInSortList.count - 1) {
                        // searchLocation Out of Upper Bounds
                        belowInputArrayItemIndex = [[inputArrayIndexesOfItemsAlsoInSortList lastObject] integerValue];
                        aboveInputArrayItemIndex = inputArray.count;
                        isSearching = NO;
                    } else {
                        // Process Search
                        aboveNumber = [inputArrayIndexesOfItemsAlsoInSortList[searchLocation] integerValue];
                        belowNumber = [inputArrayIndexesOfItemsAlsoInSortList[searchLocation - 1] integerValue];
                        
                        if (currentInputArrayItemIndex > aboveNumber) {
                            // searchLocation is Too High
                            searchLowerBound = searchLocation;
                            
                        } else if (currentInputArrayItemIndex < belowNumber) {
                            // searchLocation is Too Low
                            searchUpperBound = searchLocation - 1;
                            
                        } else {
                            belowInputArrayItemIndex = belowNumber;
                            aboveInputArrayItemIndex = aboveNumber;
                            isSearching = NO;
                        }
                    }
                }
            }
        }
        
        // Get Below, Current, & Above sortList Indexes Of Items In Both Lists / Modify moveOptionTracker to reflect situation
        currentDataSourceItemIndex = -1;
        belowDataSourceItemIndex = -1;
        aboveDataSourceItemIndex = self.dataSource.itemsSortList.count;
        moveOptionTracker = 0;
        
        if (belowInputArrayItemIndex > -1) {
            belowDataSourceItemIndex = [sortList indexOfObject:((Item *)inputArray[belowInputArrayItemIndex]).name];
            moveOptionTracker += 1;
        }
        
        if (aboveInputArrayItemIndex < inputArray.count) {
            aboveDataSourceItemIndex = [sortList indexOfObject:((Item *)inputArray[aboveInputArrayItemIndex]).name];
            moveOptionTracker += 2;
        }
        
        if ([inputArrayIndexesOfItemsAlsoInSortList containsObject:@(currentInputArrayItemIndex)]) {
            currentDataSourceItemIndex = [sortList indexOfObject:((Item *)inputArray[currentInputArrayItemIndex]).name];
            moveOptionTracker += 4;
        }
        
        // Sort Each Item In sortList
        NSString *tempName;
        switch (moveOptionTracker) {
            case 0: // No Items
                [sortList addObject:item.name];
                break;
            case 1: // Below Item
                placeToAddIndex = belowDataSourceItemIndex + 1;
                if (placeToAddIndex <= lastItemSortListIndex) placeToAddIndex = lastItemSortListIndex + 1;
                [sortList insertObject:item.name atIndex:placeToAddIndex];
                lastItemSortListIndex = placeToAddIndex;
                break;
            case 2: // Above Item
                [sortList insertObject:item.name atIndex:aboveDataSourceItemIndex];
                break;
            case 3: // Below && Above Items
                placeToAddIndex = ceilf((belowDataSourceItemIndex + aboveDataSourceItemIndex) / 2.0);
                if (placeToAddIndex <= lastItemSortListIndex) placeToAddIndex = lastItemSortListIndex + 1;
                [sortList insertObject:item.name atIndex:placeToAddIndex];
                lastItemSortListIndex = placeToAddIndex;
                break;
            case 4: // Current Item
                // Do Nothing
                break;
            case 5: // Below && Current Items
                if (currentDataSourceItemIndex < belowDataSourceItemIndex) { // This Will NEVER Be True
                    [sortList removeObjectAtIndex:currentDataSourceItemIndex];
                    belowDataSourceItemIndex--; // Adjust For Deletion
                    [sortList insertObject:item.name atIndex:belowDataSourceItemIndex + 1];
                    lastItemSortListIndex = belowDataSourceItemIndex + 1;
                }
                break;
            case 6: // Above && Current Items
                if (currentDataSourceItemIndex > aboveDataSourceItemIndex) {
                    [sortList removeObjectAtIndex:currentDataSourceItemIndex];
                    [sortList insertObject:item.name atIndex:aboveDataSourceItemIndex];
                    lastItemSortListIndex = aboveDataSourceItemIndex;
                }
                break;
            case 7: // Below && Above && Current Items
                if (currentDataSourceItemIndex < belowDataSourceItemIndex) { // This Will NEVER Be True
                    tempName = sortList[belowDataSourceItemIndex];
                    [sortList removeObjectAtIndex:belowDataSourceItemIndex];
                    [sortList insertObject:tempName atIndex:currentDataSourceItemIndex];
                    lastItemSortListIndex = currentDataSourceItemIndex + 1;
                }
                if (currentDataSourceItemIndex > aboveDataSourceItemIndex) {
                    //                    // Possibly Add
                    //                    placeToAddIndex = ceilf((belowDataSourceItemIndex + aboveDataSourceItemIndex) / 2.0);
                    //                    if (placeToAddIndex <= lastItemSortListIndex) placeToAddIndex = lastItemSortListIndex + 1;
                    //                    [sortList removeObjectAtIndex:currentDataSourceItemIndex];
                    //                    [sortList insertObject:item.name atIndex:placeToAddIndex];
                    //                    lastItemSortListIndex = placeToAddIndex;
                    
                    tempName = sortList[aboveDataSourceItemIndex];
                    [sortList removeObjectAtIndex:aboveDataSourceItemIndex];
                    currentDataSourceItemIndex--; // Adjust for Deletion
                    [sortList insertObject:tempName atIndex:currentDataSourceItemIndex + 1];
                    lastItemSortListIndex = currentDataSourceItemIndex;
                }
        }
    }
    
    // Delete Checked Items From List
    NSMutableArray *tempArray = [NSMutableArray new];
    for (Item *item in self.selectedStore.items) {
        if (!item.isChecked) {
            [tempArray addObject:item];
        }
    }
    
    if (tempArray.count == 0) {
        [self.dataSource removeStore:self.selectedStore];
    } else {
        [self.selectedStore replaceShoppingItems:tempArray];
    }
    
    [inputArray removeAllObjects]; // Will Always Be self.haveItems
    [self.dataSource save];
}


#pragma mark - UITableView Delegate && DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? self.needItems.count : self.haveItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    if (section == 0) {
        sectionTitle = @"NEED";
    } else if (section == 1) {
        sectionTitle = @"HAVE";
    }
    
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = (indexPath.section == 0) ? self.needItems[indexPath.row] : self.haveItems[indexPath.row];
    ShoppingItemCell *cell;
    if ([item.notes isEqualToString:@""]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCellWithNotes" forIndexPath:indexPath];
    }
    
    cell.itemNameLabel.text = [NSString stringWithFormat:@"(%lu) %@", (unsigned long)item.amountNeeded, item.name];
    cell.itemNotesLabel.text = item.notes;
    NSString *checkboxImageName = item.isChecked ? @"Checked_Checkbox" : @"Unchecked_Checkbox";
    cell.checkboxImage.image = [UIImage imageNamed:checkboxImageName];
    cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    cell.backgroundColor = item.colorFromTemp;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *selectedItem = (indexPath.section == 0) ? self.needItems[indexPath.row] : self.haveItems[indexPath.row];
    selectedItem.isChecked = !selectedItem.isChecked;
    
    if (selectedItem.isChecked) {
        // Assign selectedItem.checkedOrder to equal # of Checked Items + 1 (starts at 0)
        selectedItem.checkedOrder = 0;
        for (Item *item in self.selectedStore.items) {
            if (item.isChecked) {
                selectedItem.checkedOrder++;
            }
        }
    } else {
        // Re-Assign .checkedOrder After Removal
        NSMutableArray *tempArray = [NSMutableArray new];
        for (Item *item in self.selectedStore.items) {
            if (item.isChecked) {
                [tempArray addObject:item];
            }
        }
        
        NSSortDescriptor *haveSorter = [[NSSortDescriptor alloc] initWithKey:@"checkedOrder" ascending:YES];
        [tempArray sortUsingDescriptors:@[haveSorter]];
        for (Item *checkedItem in tempArray) {
            checkedItem.checkedOrder = [tempArray indexOfObject:checkedItem];
        }
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.currentCellIndex = indexPath;
    [self performSegueWithIdentifier:@"ToItem" sender:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentCellIndex = indexPath;
        [self.confirmDeleteAlert show];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor highlightedCellColor];
        [self.tableView setEditing:NO animated:YES];
    }
}


#pragma mark - UIAlertView Delegate Methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.confirmDeleteAlert) {
        if (buttonIndex == 0) { // Never Mind Button
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.currentCellIndex];
            cell.backgroundColor = [UIColor whiteColor];
        } else if (buttonIndex == 1) { // Delete Button
            NSMutableArray *currentSubList = (self.currentCellIndex.section == 0) ? self.needItems : self.haveItems;
            Item *item = currentSubList[self.currentCellIndex.row];
            
            // Delete Item from dataSource
            [self.selectedStore removeShoppingItems:@[item]];
            
            if (!self.selectedStore.items.count) {
                [self.dataSource removeStore:self.selectedStore];
            }
            [self.dataSource save];
            
            // Delete Item from tableView
            [currentSubList removeObject:item];
            [self.tableView deleteRowsAtIndexPaths:@[self.currentCellIndex] withRowAnimation:UITableViewRowAnimationLeft];
            
            // Pop View If No Items In Store List
            if (self.selectedStore.items.count) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}


#pragma mark - Lazy Instantiation


- (NSMutableArray *)needItems
{
    if (!_needItems) _needItems = [NSMutableArray new];
    return _needItems;
}

- (NSMutableArray *)haveItems
{
    if (!_haveItems) _haveItems = [NSMutableArray new];
    return _haveItems;
}

- (NSArray *)rightBarButtons
{
    if (!_rightBarButtons) {
        UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneShopping)];
        _rightBarButtons = @[addBarButton, doneBarButton];
    }
    return _rightBarButtons;
}

- (UIRefreshControl *)pullRefreshControl
{
    if (!_pullRefreshControl) {
        _pullRefreshControl = [UIRefreshControl new];
        _pullRefreshControl.tintColor = [UIColor colorWithRed:0.54 green:0.76 blue:0.95 alpha:0.45];
        [_pullRefreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    }
    return _pullRefreshControl;
}

- (UIAlertView *)confirmDeleteAlert
{
    if (!_confirmDeleteAlert) _confirmDeleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                                 message:@"Are you sure you want to delete item?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Never Mind"
                                                       otherButtonTitles:@"Delete!", nil];
    return _confirmDeleteAlert;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToItem"]) {
        ShoppingItemViewController *destVC = segue.destinationViewController;
        NSIndexPath *indexPath = self.currentCellIndex;
        
        destVC.item = (indexPath.section == 0) ? self.needItems[indexPath.row] : self.haveItems[indexPath.row];
        destVC.dataSource = self.dataSource;
        destVC.segueIdentifier = segue.identifier;
    } else if ([segue.identifier isEqualToString:@"ToNewItem"]) {
        Item *item = [[Item alloc] initGenericItem];
        [self.selectedStore addShoppingItems:@[item]];
        
        ShoppingItemViewController *destVC = segue.destinationViewController;
        destVC.item = item;
        destVC.dataSource = self.dataSource;
        destVC.segueIdentifier = segue.identifier;
    }
}

@end
