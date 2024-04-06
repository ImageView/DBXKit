//
//  DBXLog.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/6.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXConfig.h"

// 配置
@implementation DBXConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXConfig *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

@end
