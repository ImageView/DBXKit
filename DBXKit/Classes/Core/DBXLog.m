//
//  DBXLog.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXLog.h"
#include <stdio.h>

static DBXLogFormat gDBXLogFormatValue = DBXLogFormatDisable;
static DBXLogFormat gDBXDebugLogFormatValue = DBXLogFormatBasic;

void DBXLogInfo(const char *prefix, const char *file, const char *function, int line, NSString *format, ...) {
    DBXLogFormat logFormate = prefix ? gDBXDebugLogFormatValue : gDBXLogFormatValue;
    if (logFormate == DBXLogFormatDisable) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if (!prefix) {
        prefix = "";
    }
    if (logFormate == DBXLogFormatAll) {
        fprintf(stderr, "%s(%s:%d) %s %s\n", prefix, file, line, function, [log UTF8String]);
    } else {
        NSMutableString *output = [NSMutableString stringWithCString:prefix encoding:NSUTF8StringEncoding];
        if (logFormate & DBXLogFormatLogFile) {
            [output appendFormat:@"(%s:%d)",file, line];
        }
        if (logFormate & DBXLogFormatLogFunction) {
            [output appendFormat:@" %s", function];
        }
        [output appendString:log];
        fprintf(stderr, "%s\n", [output UTF8String]);
    }
}

@implementation DBXLogConfig

+ (void)logFormat:(DBXLogFormat)format {
    gDBXLogFormatValue = format;
}

/// 内部的调试日志配置，默认关闭
+ (void)debugLogFormat:(DBXLogFormat)format {
    gDBXDebugLogFormatValue = format;
}

@end
