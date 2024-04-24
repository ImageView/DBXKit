//
//  DBXLog.m
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/24.
//  Copyright © 2024 DBX. All rights reserved.
//

#import "DBXLog.h"

//@implementation DBXLog
//
//@end

void DBXLogInfo(const char *file, const char *function, int line, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    fprintf(stderr, "[DBX](%s:%d) %s %s\n", file, line, function, [log UTF8String]);
}
