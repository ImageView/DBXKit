//
//  DBXUnit.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/8/11.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXUnit.h"

@interface DBXUnit ()
@property(nonatomic, strong) NSString *dbxDescription;
@end

@implementation DBXUnit

+ (instancetype)voidUnit {
    static dispatch_once_t onceToken;
    static DBXUnit *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dbxDescription = @"(void)";
    });
    return instance;
}

+ (instancetype)nilUnit {
    static dispatch_once_t onceToken;
    static DBXUnit *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dbxDescription = @"(nil)";
    });
    return instance;
}

- (NSString *)description {
    return self.dbxDescription ? : [super description];
}

@end
