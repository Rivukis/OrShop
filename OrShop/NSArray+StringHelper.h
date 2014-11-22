//
//  NSArray+StringHelper.h
//  OrShop
//
//  Created by Brian Radebaugh on 11/21/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (StringHelper)

- (BOOL)containsString:(NSString *)string caseSensitive:(BOOL)caseSensitive;

@end

@interface NSMutableArray (StringHelper)

- (void)removeString:(NSString *)string caseSensitive:(BOOL)caseSensitive;

@end