//
//  ShoppingItemViewController.m
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "ShoppingItemViewController.h"
#import "AutoCompleteView.h"
#import "DataSourceController.h"
#import "Store.h"
#import "Item.h"

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
@property (strong, nonatomic) DataSourceController *dataSource;

@end

@implementation ShoppingItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDelegates];
    
    self.dataSource = [DataSourceController sharedInstance];
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
    NSString *rightBarButtonTitle;
    if ([self.segueIdentifier isEqualToString:@"ToNewItem"]) {
        [self.deleteButton removeFromSuperview];
        rightBarButtonTitle = @"Create";
        self.title = @"Create Item";
        self.item = [[Item alloc] initGenericItem];
        
    } else if ([self.segueIdentifier isEqualToString:@"ToItem"]) {
        rightBarButtonTitle = @"Save";
        self.title = @"Edit Item";
    }
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonTitle
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(createOrSaveBarButtonPressed)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonPressed)];
    cancelBarButton.tintColor = [UIColor redColor];
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
    
    [self setItemNamePlaceholderWithAttributedString:[ShoppingItemViewController redItemNamePlaceholderAttributedString]];
    
    if ([self.storeName isEqualToString:[DataSourceController stringWithNoStoreName]]) {
        self.preferredStoreTextField.text = @"";
    } else {
        self.preferredStoreTextField.text = self.storeName;
    }
    
    self.itemNameTextField.text = self.item.name;
    self.amountNeededTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.item.amountNeeded];
    self.amountNeededStepper.value = self.item.amountNeeded;
    self.tempAtPurchaseSegmentedControl.selectedSegmentIndex = self.item.temperatureType;
    self.notesTextField.text = self.item.notes;
}


#pragma mark - Create, Save, or Cancel


- (void)createOrSaveBarButtonPressed
{
    [self resignKeyboard];
    
    if ([self canItemBeSaved]) {
        
        NSString *updatedStoreName = self.preferredStoreTextField.text;
        if ([updatedStoreName isEqualToString:@""]) {
            updatedStoreName = [DataSourceController stringWithNoStoreName];
        }
        
        if ([self.segueIdentifier isEqualToString:@"ToItem"]) {
            if (![self.storeName isEqualToString:updatedStoreName]) {
                [self.dataSource moveItem:self.item fromStoreWithName:self.storeName toStoreWithName:updatedStoreName];
            }
            
        } else if ([self.segueIdentifier isEqualToString:@"ToNewItem"]) {
            Store *store = [self.dataSource storeWithName:updatedStoreName];
            if (store) {
                [store addShoppingItems:@[self.item]];
            } else {
                store = [[Store alloc] initWithName:self.preferredStoreTextField.text items:@[self.item]];
                [self.dataSource addStore:store];
            }
        }
        
        if (![self.storeName isEqualToString:self.preferredStoreTextField.text]) {
            [self.dataSource addToStoreNamesUsed:self.preferredStoreTextField.text];
        }
        
        if (![self.item.name isEqualToString:self.itemNameTextField.text]) {
            [self.dataSource removeFromItemNamesUsed:self.item.name];
            [self.dataSource addToItemNamesUsed:self.itemNameTextField.text];
        }
        
        self.item.name = self.itemNameTextField.text;
        self.item.amountNeeded = self.amountNeededStepper.value;
        self.item.temperatureType = self.tempAtPurchaseSegmentedControl.selectedSegmentIndex;
        self.item.notes = self.notesTextField.text;
        
        [self.dataSource save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancelBarButtonPressed
{
    [self resignKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)canItemBeSaved
{
    if ([self.itemNameTextField.text isEqualToString:@""]) {
        [self playItemNameRequiredAnimation];
        return NO;
    }
    
    if (![self.item.name.lowercaseString isEqualToString:self.itemNameTextField.text.lowercaseString]) {
        NSArray *storeAndItemNames = [self.dataSource storeAndItemNameForItemString:self.itemNameTextField.text];
        if (storeAndItemNames) {
            NSString *title = @"Item Already Exists!";
            NSString *message = [NSString stringWithFormat:@"%@ is already in %@ list.", storeAndItemNames[1], storeAndItemNames[0]];
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


#pragma mark - User Input


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
        Store *store = [self.dataSource storeWithName:self.storeName];
        [store removeShoppingItems:@[self.item]];
        
        if (store.items.count == 0) {
            [self.dataSource removeStore:store];
        }
        
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

- (NSString *)storeName {
    if (!_storeName) _storeName = @"";
    return _storeName;
}

@end
