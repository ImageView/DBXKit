//
//  DBXConfig.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/7/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// dbx组件hook其他函数后产生的新的函数的统一前缀
static NSString *const kDBXHookMethodPrefix = @"__dbx_";

typedef NS_OPTIONS(NSInteger, DBXLogOption) {
    DBXLogOptionDisable = 0,                                            // 关闭日志
    DBXLogOptionBasic = (1 << 0),                                       // 基本内容，只有日志信息本身
    DBXLogOptionLogFile = (1 << 1),                                     // 包含打印日志的文件名和所在行
    DBXLogOptionLogFunction = (1 << 2),                                 // 包含打印日志的函数名
    DBXLogOptionLogThread = (1 << 3),                                   // 包含打印日志所在的线程
    DBXLogOptionAll = DBXLogOptionLogFile | DBXLogOptionLogFunction | DBXLogOptionLogThread     // 全部包含
};

typedef NS_OPTIONS(NSInteger, DBXFunctionAvailable) {
    DBXFunctionAvailableNull = 0,               // 全部关闭
    DBXFunctionAvailableTrack = (1 << 0),       // 追踪功能
    DBXFunctionAvailableClickedArea = (1 << 1), // 点击区域功能
    DBXFunctionAvailableDebounce = (1 << 2),    // 防抖
    DBXFunctionAvailableStubs = (1 << 3),       // 网络模拟
    DBXFunctionAvailableGuard = (1 << 4),       // 函数禁用
    
    DBXFunctionAvailableAll = DBXFunctionAvailableTrack | DBXFunctionAvailableClickedArea | DBXFunctionAvailableDebounce | DBXFunctionAvailableStubs | DBXFunctionAvailableGuard
};

// 初始化配置
@interface DBXConfig : NSObject

/// 日志配置，默认basic
@property(nonatomic, assign) DBXLogOption logOption;
/// 内部的调试日志配置，默认关闭
@property(nonatomic, assign) DBXLogOption debugLogOption;
/// 对应的功能是否u开启，默认全开
@property(nonatomic, assign) DBXFunctionAvailable functionAvailable;

@end

@interface DBXCenter : NSObject

+ (DBXConfig *)sharedConfig;

// 只有第一次调用生效，避免重复修改引起一些问题
+ (void)startWithConfig:(void (^)(DBXConfig *config))updateConfigBlock;

// 检查某个功能是否可用
+ (BOOL)functionIsAvailable:(DBXFunctionAvailable)func;

@end

NS_ASSUME_NONNULL_END
