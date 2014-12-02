//
//  VersionController.h
//  OrShop
//
//  Created by Brian Radebaugh on 11/26/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppVersion) {
    AppVersion_1_0 = 0,
    AppVersion_1_1
};

@interface VersionController : NSObject

- (void)upgradeFromVersion:(AppVersion)oldVersion;

@end
