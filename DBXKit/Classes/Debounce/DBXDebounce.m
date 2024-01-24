//
//  DBXDebounce.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/1/22.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXDebounce.h"

@implementation DBXDebounce

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXDebounce *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)addRule:(DBXDebRule *)rule {
    
}

@end
