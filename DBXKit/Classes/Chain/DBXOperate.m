//
//  DBXOperate.m
//  DBXKit
//
//  Created by 罗俊宇 on 2022/12/2.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXOperate.h"

@interface DBXOperate ()

// 用来执行需要执行的block
@property(nonatomic, copy) void (^operateBlock)(void (^block)(void));

@end

@implementation DBXOperate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operateBlock = ^(void (^block)(void)) {
            block();
        };
    }
    return self;
}

- (void)operateBlock:(void (^)(void))block {
    self.operateBlock(block);
}

@end

@implementation DBXMainThreadOperate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operateBlock = ^(void (^block)(void)) {
            if ([NSThread isMainThread]) {
                block();
            } else {
                dispatch_async(dispatch_get_main_queue(), block);
            }
        };
    }
    return self;
}

@end


@implementation DBXGlobalThreadOperate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operateBlock = ^(void (^block)(void)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
        };
    }
    return self;
}

@end

@implementation DBXCustomThreadOperate

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        self.operateBlock = ^(void (^block)(void)) {
            dispatch_async(queue, block);
        };
    }
    return self;
}

@end


