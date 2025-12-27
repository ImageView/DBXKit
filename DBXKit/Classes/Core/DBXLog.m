//
//  DBXLog.m
//  DBXKit
//
//  Created by 调包侠 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXLog.h"
#import "DBXConfig.h"

void DBXLogInfo(const char *prefix, const char *file, const char *function, int line, NSString *format, ...) {
    DBXLogOption logOption = prefix ? [DBXCenter sharedConfig].debugLogOption : [DBXCenter sharedConfig].logOption;
    if (logOption == DBXLogOptionDisable) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    if (!prefix) {
        prefix = "";
    }
    NSMutableString *output = [NSMutableString stringWithCString:prefix encoding:NSUTF8StringEncoding];
    if (logOption & DBXLogOptionLogFile) {
        [output appendFormat:@"(%s:%d)",file, line];
    }
    if (logOption & DBXLogOptionLogFunction) {
        [output appendFormat:@" %s", function];
    }
    if (logOption & DBXLogOptionLogThread) {
        NSThread *currentThread = [NSThread currentThread];
        NSString *threadInfo = nil;
        if ([currentThread isMainThread]) {
            threadInfo = @"(Thread Main)";
        } else {
            NSError *error = nil;
            NSString *threadDescription = [currentThread description];
            NSString *threadNumber = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"number = (\\d+)" options:0 error:&error];
            if (!error) {
                NSTextCheckingResult *match = [regex firstMatchInString:threadDescription options:0 range:NSMakeRange(0, [threadDescription length])];
                if (match) {
                    // 提取并打印线程编号
                    threadNumber = [threadDescription substringWithRange:[match rangeAtIndex:1]];
                }
            }
            if ([currentThread.name isKindOfClass:[NSString class]] && currentThread.name.length > 0) {
                threadInfo = [NSString stringWithFormat:@"(Thread %@ %@)", threadNumber, currentThread.name];
            } else {
                threadInfo = [NSString stringWithFormat:@"(Thread %@)", threadNumber];
            }
        }
        [output appendString:threadInfo];
    }
    [output appendString:log];
    NSLog(@"%@", output);
}

