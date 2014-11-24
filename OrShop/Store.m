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
        self.name = (name) ? name : [NSString string];
        self.items = (items) ? items : [NSArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.items forKey:@"items"];
}

- (void)addShoppingItems:(NSArray *)items {
    self.items = [self.items arrayByAddingObjectsFromArray:items];
}

- (void)removeShoppingItems:(NSArray *)items {
    NSMutableArray *tempArray = [self.items mutableCopy];
    [tempArray removeObjectsInArray:items];
    self.items = [tempArray copy];
}

- (void)replaceShoppingItems:(NSArray *)items {
    self.items = [items copy];
}

@end
