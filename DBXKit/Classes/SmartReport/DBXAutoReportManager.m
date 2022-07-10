//
//  DBXAutoReportManager.m
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXAutoReportManager.h"

@implementation DBXAutoReportManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXAutoReportManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)enableAutoReport {
    
}

@end
