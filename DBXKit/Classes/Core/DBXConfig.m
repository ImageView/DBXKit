//
//  DBXConfig.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/7/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXConfig.h"

@implementation DBXConfig


@end

@interface DBXCenter ()
// 配置
@property(nonatomic, strong) DBXConfig *config;
@end

@implementation DBXCenter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXCenter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        DBXConfig *config = [[DBXConfig alloc] init];
        config.debugLogOption = DBXLogOptionDisable;
        config.logOption = DBXLogOptionBasic;
        config.functionAvailable = DBXFunctionAvailableAll;
        self.config = config;
    }
    return self;
}

+ (BOOL)functionIsAvailable:(DBXFunctionAvailable)func {
    return [DBXCenter sharedInstance].config.functionAvailable & func;
}

+ (DBXConfig *)sharedConfig {
    return [DBXCenter sharedInstance].config;
}

+ (void)startWithConfig:(void (^)(DBXConfig *config))updateConfigBlock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (updateConfigBlock) {
            updateConfigBlock([DBXCenter sharedInstance].config);
        }
    });
}

@end
