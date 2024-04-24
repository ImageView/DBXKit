//
//  DBXLog.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

//@interface DBXLog : NSObject
//
//@end

// 自定义日志打印方法
void DBXLogInfo(const char *file, const char *function, int line, NSString *format, ...);

#if DEBUG
#define DBXLog(format, ...) DBXLogInfo(strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#else
#define DBXLog(format, ...) {}
#endif


NS_ASSUME_NONNULL_END
