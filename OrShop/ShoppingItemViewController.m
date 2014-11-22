//
//  ShoppingItemViewController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "ShoppingItemViewController.h"
#import "AutoCompleteView.h"

@interface ShoppingItemViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, AutoCompleteViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *preferredStoreTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountNeededTextField;
@property (weak, nonatomic) IBOutlet UIStepper *amountNeededStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempAtPurchaseSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) UITapGestureRecognizer *tapToDismissKeyboard;
@property (strong, nonatomic) UIAlertView *deleteAlert;
@property (strong, nonatomic) AutoCompleteView *autoCompleteView;
@property (strong, nonatomic) UITextField *textFieldBeingEdited;

@end

@implementation ShoppingItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDelegates];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self loadViewBasedOnSegueIdentifier];
}

- (void)setDelegates
{
    self.itemNameTextField.delegate = self;
    self.preferredStoreTextField.delegate = self;
    self.amountNeededTextField.delegate = self;
    self.notesTextField.delegate = self;
    self.tapToDismissKeyboard.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadViewBasedOnSegueIdentifier
{
    if ([self.segueIdentifier isEqualToString:@"ToNewItem"]) {
        // New Item Setup
        [self.deleteButton removeFromSuperview];
        UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createOrSaveBarButtonPressed)];
        [self.navigationItem setRightBarButtonItem:createBarButton];
        self.title = @"Create Item";
    } else {
        // Existing Item Setup
        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(createOrSaveBarButtonPressed)];
        [self.navigationItem setRightBarButtonItem:saveBarButton];
        self.title = @"Edit Item";
    }
    
    // Generic Item Setup
    [self setItemNamePlaceholderWithAttributedString:[ShoppingItemViewController redItemNamePlaceholderAttributedString]];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonPressed)];
    cancelBarButton.tintColor = [UIColor redColor];
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
    
    // Load Item Properties
    self.itemNameTextField.text = self.item.name;
    self.preferredStoreTextField.text = ([self.item.preferredStore isEqualToString:[DataSourceController stringWithNoStoreName]]) ? @"" : self.item.preferredStore;
    self.amountNeededTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.item.amountNeeded];
    self.amountNeededStepper.value = self.item.amountNeeded;
    self.tempAtPurchaseSegmentedControl.selectedSegmentIndex = self.item.tempAtPurchase;
    self.notesTextField.text = self.item.notes;
}


#pragma mark - User Actions


- (void)createOrSaveBarButtonPressed
{
    [self resignKeyboard];
    
    if ([self canItemBeSaved]) {
        if ([self.preferredStoreTextField.text isEqualToString:@""]) {
            self.preferredStoreTextField.text = [DataSourceController stringWithNoStoreName];
        }
        if (![self.item.preferredStore isEqualToString:self.preferredStoreTextField.text]) {
            [self.dataSource moveItem:self.item fromStore:self.item.preferredStore toStore:self.preferredStoreTextField.text];
        }
        [self.dataSource removeFromItemNamesUsed:self.item.name];
        
        self.item.preferredStore = self.preferredStoreTextField.text;
        self.item.name = self.itemNameTextField.text;
        self.item.amountNeeded = self.amountNeededStepper.value;
        self.item.tempAtPurchase = self.tempAtPurchaseSegmentedControl.selectedSegmentIndex;
        self.item.notes = self.notesTextField.text;
        
        // Add To Auto-Complete Lists
        [self.dataSource addToStoreNamesUsed:self.item.preferredStore];
        [self.dataSource addToItemNamesUsed:self.item.name];
        
        [self.dataSource save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)canItemBeSaved
{
    if ([self.itemNameTextField.text isEqualToString:@""]) {
        [self playItemNameRequiredAnimation];
        return NO;
    }
    
    if (![self.item.name.lowercaseString isEqualToString:self.itemNameTextField.text.lowercaseString]) {
        NSString *itemStoreName = [self.dataSource storeNameForItemName:self.itemNameTextField.text];
        if (![itemStoreName isEqualToString:@""]) {
            NSString *title = @"Item Already Exists!";
            NSString *message = [NSString stringWithFormat:@"This item is already in %@ list.", itemStoreName];
            UIAlertView *itemExistsInThisListAlert = [[UIAlertView alloc] initWithTitle:title
                                                                                message:message
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
            [itemExistsInThisListAlert show];
            return NO;
        }
    }
    
    return YES;
}

// TODO: move moveToNewStore method to DataSourceController
//- (void)moveToNewStore
//{
//    NSString *oldStoreName = self.item.preferredStore;
//    NSString *newStoreName = self.preferredStoreTextField.text;
//    if ([newStoreName isEqualToString:@""]) newStoreName = [DataSourceController stringWithNoStoreName];
//    NSMutableArray *oldStoreList = self.dataSource.lists[oldStoreName];
//    NSMutableArray *newStoreList;
//    self.item.isChecked = NO;
//    
//    // Get New Store List
//    if ([[self.dataSource.lists allKeys] indexOfObject:newStoreName] == NSNotFound) {
//        newStoreList = [NSMutableArray new];
//        [self.dataSource.lists setObject:newStoreList
//                                  forKey:[NSString stringWithString:newStoreName]];
//    } else {
//        newStoreList = self.dataSource.lists[newStoreName];
//    }
//    
//    // Add Item to New Store List
//    [newStoreList addObject:self.item];
//    
//    // Remove Item From Old Store List
//    [oldStoreList removeObject:self.item];
//    if (!oldStoreList.count) [self.dataSource.lists removeObjectForKey:oldStoreName];
//}

- (void)cancelBarButtonPressed
{
    [self resignKeyboard];
    
    if ([self.segueIdentifier isEqualToString:@"ToNewItem"]) {
        NSUInteger lastItemIndex = [self.dataSource.lists[self.item.preferredStore] count] - 1;
        [self.dataSource.lists[self.item.preferredStore] removeObjectAtIndex:lastItemIndex];
        if ([self.dataSource.lists[self.item.preferredStore] count] == 0) {
            [self.dataSource.lists removeObjectForKey:self.item.preferredStore];
        }
        [self.dataSource save];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)itemNameTextFieldEditingChanged:(UITextField *)sender
{
    [self.autoCompleteView reloadDataSourceUsingArray:self.dataSource.itemNamesUsed andString:sender.text];
}

- (IBAction)preferredStoreTextFieldEditingChanged:(UITextField *)sender
{
    [self.autoCompleteView reloadDataSourceUsingArray:self.dataSource.storeNamesUsed andString:sender.text];
}

- (IBAction)amountNeededTextField:(UITextField *)sender {
    int newAmount = [self.amountNeededTextField.text intValue];
    
    if (newAmount >= self.amountNeededStepper.minimumValue && newAmount <= self.amountNeededStepper.maximumValue) {
        self.amountNeededStepper.value = newAmount;
    } else {
        self.amountNeededTextField.text = [NSString stringWithFormat:@"%d", (int)self.amountNeededStepper.value];
    }
}

- (IBAction)amountNeededStepper:(UIStepper *)sender {
    self.amountNeededTextField.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (IBAction)deleteButton:(UIButton *)sender
{
    [self.deleteAlert show];
}

- (void)resignKeyboard
{
    for (UITextField *textField in self.subView.subviews) [textField resignFirstResponder];
}


#pragma mark - Item Name Animation Methods


- (void)playItemNameRequiredAnimation {
    NSAttributedString *redAttributedString = [ShoppingItemViewController redItemNamePlaceholderAttributedString];
    NSAttributedString *grayAttributedString = [ShoppingItemViewController grayItemNamePlaceholderAttributedString];
    
    [self setItemNamePlaceholderWithAttributedString:grayAttributedString];
    [self performSelector:@selector(setItemNamePlaceholderWithAttributedString:) withObject:redAttributedString afterDelay:0.2f];
    [self performSelector:@selector(setItemNamePlaceholderWithAttributedString:) withObject:grayAttributedString afterDelay:0.4f];
    [self performSelector:@selector(setItemNamePlaceholderWithAttributedString:) withObject:redAttributedString afterDelay:0.6f];
}

+ (NSAttributedString *)redItemNamePlaceholderAttributedString {
    UIColor *lightRedColor = [UIColor colorWithRed:1.0f green:0.0 blue:0.0 alpha:0.4f];
    return [ShoppingItemViewController itemNamePlaceholderAttributedStringWithColor:lightRedColor];
}

+ (NSAttributedString *)grayItemNamePlaceholderAttributedString {
    UIColor *lightGrayColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
    return [ShoppingItemViewController itemNamePlaceholderAttributedStringWithColor:lightGrayColor];
}

+ (NSAttributedString *)itemNamePlaceholderAttributedStringWithColor:(UIColor *)color {
    NSString *placeholderString = @"Required";
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14.0f];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color};
    
    return  [[NSAttributedString alloc] initWithString:placeholderString attributes:attributes];
}

- (void)setItemNamePlaceholderWithAttributedString:(NSAttributedString *)attributedString {
    self.itemNameTextField.attributedPlaceholder = attributedString;
}


#pragma mark - UIGestureRecognizer Delegate Methods


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.subView) ? YES : NO;
}


#pragma mark - UIAlertView Delegate Methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Delete Alert
    if (alertView == self.deleteAlert && buttonIndex == 1) { // 1 == Delete Selected
        NSString *storeName = self.item.preferredStore;
        NSMutableArray *storeList = self.dataSource.lists[storeName];
        
        [storeList removeObject:self.item];
        if (!storeList.count) [self.dataSource.lists removeObjectForKey:storeName];
        [self.dataSource save];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UITextField Delegate


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != self.amountNeededTextField) self.amountNeededStepper.enabled = NO;
    self.tempAtPurchaseSegmentedControl.enabled = NO;
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 150) animated:YES];
    [self.navigationController.view addGestureRecognizer:self.tapToDismissKeyboard];
    
    if (textField == self.itemNameTextField || textField == self.preferredStoreTextField) {
        self.textFieldBeingEdited = textField;
        [self createAutoCompleteDropDownForTextField:textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self deleteAutoCompleteDropDown];
    self.textFieldBeingEdited = nil;
    
    self.amountNeededStepper.enabled = YES;
    self.tempAtPurchaseSegmentedControl.enabled = YES;
    [self.navigationController.view removeGestureRecognizer:self.tapToDismissKeyboard];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[textField superview] viewWithTag:textField.tag + 1]) {
        [[[textField superview] viewWithTag:textField.tag + 1] becomeFirstResponder];
    } else {
        [self resignKeyboard];
    }
    
    return NO;
}


#pragma mark - AutoCompleteView Create, Destroy, and Delegate


- (void)createAutoCompleteDropDownForTextField:(UITextField *)textField
{
    self.autoCompleteView = [[AutoCompleteView alloc] initWithTextField:textField];
    self.autoCompleteView.delegate = self;
    [self.subView addSubview:self.autoCompleteView];
}

- (void)deleteAutoCompleteDropDown
{
    [self.autoCompleteView removeFromSuperview];
    self.autoCompleteView = nil;
}

- (void)autoCompleteCellClickedWithTitleString:(NSString *)string
{
    self.textFieldBeingEdited.text = string;
    [self.textFieldBeingEdited endEditing:YES];
}


#pragma mark - Lazy Instantiation


- (UITapGestureRecognizer *)tapToDismissKeyboard
{
    if (!_tapToDismissKeyboard) _tapToDismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    return _tapToDismissKeyboard;
}

- (UIAlertView *)deleteAlert
{
    if (!_deleteAlert) _deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                                 message:@"Are you sure you want to delete item?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Never Mind"
                                                       otherButtonTitles:@"Delete!", nil];
    return _deleteAlert;
}

@end
