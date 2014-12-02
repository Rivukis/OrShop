//
//  AppDelegate.h
//  OrShop
//
//  Created by Brian Radebaugh on 4/11/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataSourceController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end


/*
 FOUND BUGS:
 
 - app crashes when moving all items from one list to another list
    - operation completes as normal
    - the crash happens because the table view reloading
        - the number of cells removed/added don't match the amount datasource items removed/added
*/