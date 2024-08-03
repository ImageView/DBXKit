//
//  DBXConfig.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/7/28.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, DBXLogOption) {
    DBXLogOptionDisable = 0,                                            // 关闭日志
    DBXLogOptionBasic = 1 << 0,                                         // 基本内容，只有日志信息本身
    DBXLogOptionLogFile = (1 << 1),                                     // 包含打印日志的文件名和所在行
    DBXLogOptionLogFunction = (1 << 2),                                 // 包含打印日志的函数名
    DBXLogOptionLogThread = (1 << 3),                                   // 包含打印日志所在的线程
    DBXLogOptionAll = DBXLogOptionLogFile | DBXLogOptionLogFunction | DBXLogOptionLogThread     // 全部包含
};

// 初始化配置
@interface DBXConfig : NSObject

/// 日志配置，默认basic
@property(nonatomic, assign) DBXLogOption logOption;
/// 内部的调试日志配置，默认关闭
@property(nonatomic, assign) DBXLogOption debugLogOption;
/// 是否关闭暂时部分灰度功能，默认NO
@property(nonatomic, assign) BOOL closeUnsafeFeatures;

@end

@interface DBXCenter : NSObject

+ (DBXConfig *)sharedConfig;

// 只有第一次调用生效，避免重复修改引起一些问题
+ (void)initWithConfig:(DBXConfig *)config;

@end

NS_ASSUME_NONNULL_END
