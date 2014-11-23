//
//  Store.m
//  OrShop
//
//  Created by Brian Radebaugh on 11/22/14.
//  Copyright (c) 2014 Brian Radebaugh. All rights reserved.
//

#import "Store.h"

@interface Store ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *items;

@end

@implementation Store

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithName:(NSString *)name items:(NSArray *)items {
    self = [super init];
    if (self) {
        self.name = name;
        self.items = items;
    }
    return self;
}

- (void)addShoppingItems:(NSArray *)items {
    self.items = [[self.items arrayByAddingObjectsFromArray:items] mutableCopy];
}

- (void)removeShoppingItems:(NSArray *)items {
    NSMutableArray *tempArray = [self.items mutableCopy];
    [tempArray removeObjectsInArray:items];
    self.items = [tempArray copy];
}

@end
