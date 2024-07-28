//
//  DBXLog.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXLog.h"
#include <stdio.h>
#import "DBXConfig.h"

void DBXLogInfo(const char *prefix, const char *file, const char *function, int line, NSString *format, ...) {
    DBXLogFormat logFormate = prefix ? [DBXCenter sharedConfig].debugLogFormat : [DBXCenter sharedConfig].logFormat;
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
        NSLog( @"%s(%s:%d) %s %s\n", prefix, file, line, function, [log UTF8String]);
    } else {
        NSMutableString *output = [NSMutableString stringWithCString:prefix encoding:NSUTF8StringEncoding];
        if (logFormate & DBXLogFormatLogFile) {
            [output appendFormat:@"(%s:%d)",file, line];
        }
        if (logFormate & DBXLogFormatLogFunction) {
            [output appendFormat:@" %s", function];
        }
        [output appendString:log];
        NSLog( @"%s\n", [output UTF8String]);
    }
}

