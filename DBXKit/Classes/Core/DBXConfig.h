//
//  DBXLog.h
//  DBXKit
//
//  Created by 罗俊宇 on 2024/4/6.
//  Copyright © 2024 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 配置
@interface DBXConfig : NSObject

// 调试模式
@property(nonatomic, assign) BOOL debug;

+ (instancetype)sharedInstance;

@end

static void DBXLog(NSString *log, ...) {
    if (!(DEBUG && [DBXConfig sharedInstance].debug)) {
        return;
    }
    
    va_list args;
    va_start(args, log);
    NSLog(@"%@", [[NSString alloc] initWithFormat:log arguments:args]);
    va_end(args);
}

NS_ASSUME_NONNULL_END
