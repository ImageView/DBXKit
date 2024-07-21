//
//  DBXLog.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, DBXLogFormat) {
    DBXLogFormatDisable = 0,                                            // 关闭日志
    DBXLogFormatBasic = 1 << 0,                                         // 基本内容，只有日志信息本身
    DBXLogFormatLogFile = (1 << 1),                                     // 包含打印日志的文件名和所在行
    DBXLogFormatLogFunction = (1 << 2),                                 // 包含打印日志的函数名
    DBXLogFormatAll = DBXLogFormatLogFile | DBXLogFormatLogFunction     // 全部包含
};

/// 自定义日志打印方法
/// - Parameters:
///   - prefix: 前缀
///   - file: 文件名
///   - function: 函数名
///   - line: 行数
///   - format: 日志内容
void DBXLogInfo(const char *__nullable prefix, const char *file, const char *function, int line, NSString *format, ...);

#if DEBUG
#define DBXLog(format, ...) DBXLogInfo(NULL, strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#else
#define DBXLog(format, ...) {}
#endif

// sdk内部使用，包含了前缀
#if DEBUG
#define DBXpLog(format, ...) DBXLogInfo("[DBX]", strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#else
#define DBXpLog(format, ...) {}
#endif

@interface DBXLogConfig : NSObject

/// 日志配置，默认basic
+ (void)logFormat:(DBXLogFormat)format;

/// 内部的调试日志配置，默认关闭
+ (void)debugLogFormat:(DBXLogFormat)format;

@end
NS_ASSUME_NONNULL_END
