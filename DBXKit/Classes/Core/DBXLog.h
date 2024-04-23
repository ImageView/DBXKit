//
//  DBXLog.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/23.
//  Copyright © 2024 DBX. All rights reserved.
//

#ifndef DBXLog_h
#define DBXLog_h

#include <stdio.h>

// 自定义日志打印方法
void DBXLogInfo(const char *file, const char *function, int line, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stderr, "[DBX](%s:%d) %s %s\n", file, line, function, [log UTF8String]);
}

#if DEBUG
#define DBXLog(format, ...) DBXLogInfo(strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#else
#define DBXLog(format, ...) {}
#endif

#endif /* DBXLog_h */
