//
//  DBXAutoReportManager.m
//  DBXKit
//
//  Created by asherluo on 2022/7/10.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "DBXAutoReportManager.h"
#import "NSObject+DBXRuntime.h"
#import "UIApplication+DBXAR.h"
#import "UIView+DBXAR.h"
#import "DBXARUtils.h"

@interface DBXAutoReportManager ()

// 存储配置
@property(nonatomic, copy) NSDictionary *configsStore;
@end

// 自动上报管理类
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
        
        [UIGestureRecognizer dbx_swizzleMethod:@selector(initWithTarget:action:)
                                     newMethod:@selector(dbx_initWithTarget:action:)
                                        error:nil];
        [UIGestureRecognizer dbx_swizzleMethod:@selector(addTarget:action:)
                                     newMethod:@selector(dbx_addTarget:action:)
                                        error:nil];
        [UIGestureRecognizer dbx_swizzleMethod:@selector(removeTarget:action:)
                                     newMethod:@selector(dbx_removeTarget:action:)
                                        error:nil];
    });
}

- (void)setReportConfig:(NSDictionary *)configDic {
    self.configsStore = configDic;
}

- (void)report:(UIView *)sender {
    NSDictionary *params = [self reportParamsOfView:sender];
    NSLog(@"你点击了：%@, params:%@", sender.dbx_reportID, params);

    if (!params) {
        return;
    }
    if ([self.impl respondsToSelector:@selector(clickedView:reportParams:)]) {
        [self.impl clickedView:sender reportParams:params];
    }
}

- (NSDictionary *)reportParamsOfView:(UIView *)view {
    return [self.configsStore objectForKey:view.dbx_reportID];
}

@end
