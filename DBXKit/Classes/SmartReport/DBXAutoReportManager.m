//
//  DBXAutoReportManager.m
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXAutoReportManager.h"
#import "NSObject+DBXRuntime.h"
#import <UIKit/UIKit.h>
#import "UIApplication+DBXAutoReport.h"

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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIApplication dbx_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                               newMethod:@selector(dbx_sendAction:to:from:forEvent:)
                                  error:nil];
    });
}

@end
