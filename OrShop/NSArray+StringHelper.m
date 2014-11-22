//
//  NSArray+StringHelper.m
//  OrShop
//
//  Created by Brian Radebaugh on 11/21/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "NSArray+StringHelper.h"

@implementation NSArray (StringHelper)

- (BOOL)containsString:(NSString *)string caseSensitive:(BOOL)caseSensitive {
    if (caseSensitive) {
        return [self containsObject:string];
    }
    
    for (NSString *arrayString in self) {
        if ([arrayString isKindOfClass:[NSString class]]) {
            if ([arrayString.lowercaseString isEqualToString:string.lowercaseString]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSUInteger)indexOfString:(NSString *)string caseSensitive:(BOOL)caseSensitive {
    if (caseSensitive) {
        return [self indexOfObject:string];
    }
    
    for (NSUInteger i = 0; i < self.count; i++) {
        NSString *arrayString = self[i];
        if ([arrayString isKindOfClass:[NSString class]]) {
            if ([arrayString.lowercaseString isEqualToString:string.lowercaseString]) {
                return i;
            }
        }
    }
    
    return NSNotFound;
}

@end

@implementation NSMutableArray (StringHelper)

- (void)removeString:(NSString *)string caseSensitive:(BOOL)caseSensitive {
    if (caseSensitive) {
        [self removeObject:string];
        return;
    }
    
    for (NSString *arrayString in self) {
        if ([arrayString isKindOfClass:[NSString class]]) {
            if ([arrayString.lowercaseString isEqualToString:string.lowercaseString]) {
                [self removeObject:arrayString];
            }
        }
    }
}

@end