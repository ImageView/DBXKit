//
//  DBXOperate.h
//  DBXKit
//
//  Created by 罗俊宇 on 2022/12/2.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 默认在当前队列执行
@interface DBXOperate : NSObject

- (void)operateBlock:(void (^)(void))block;

@end

// 在主线程执行
@interface DBXMainThreadOperate : DBXOperate

@end


// 在子线程执行
@interface DBXGlobalThreadOperate : DBXOperate

@end

// 在自定义队列中执行
@interface DBXCustomThreadOperate : DBXOperate

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

@end


NS_ASSUME_NONNULL_END
