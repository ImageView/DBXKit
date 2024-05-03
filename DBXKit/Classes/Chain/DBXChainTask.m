//
//  DBXChainTask.m
//  DBXKit
//
//  Created by asherluo on 2022/07/27.
//  Copyright © 2022 DBX. All rights reserved.
//

#import "DBXChainTask.h"
#import <stdatomic.h>
#import "DBXOperate.h"
#import "DBXLog.h"

NSString *const DBXChainTaskErrorDomain = @"GroupTasks error";
NSInteger const kDBXChainMultipleErrorsCode = 20180306;

@interface DBXChainTask ()

// 存储没有立即执行的block
@property(nonatomic, strong) NSMutableArray *thenExecutBlocks;
// 线程锁
@property(nonatomic, strong) NSLock *lock;
// 标记是否任务完成
@property(nonatomic, assign, getter=isCompleted) BOOL completed;
// 用于grouptask，获取当前group里包含的task
@property(nonatomic, copy) NSArray *subTasks;
// 超时时间
@property(nonatomic, strong) NSTimer *timeOutTimer;
// 标记是否是临时任务
@property(nonatomic, assign, getter=isTempTask) BOOL tempTask;
@end

@implementation DBXChainTask

- (id)copyWithZone:(NSZone *)zone {
    DBXChainTask *task = [[self class] allocWithZone:zone];
    task.tag = self.tag;
    task.taskName = self.taskName;
    task.result = self.result;
    task.completed = self.completed;
    task.error = self.error;
    task.subTasks = self.subTasks;
    task.timeOutInterval = self.timeOutInterval;
    
    return task;
}

+ (instancetype)chainTask {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _thenExecutBlocks = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)executGroupTasks:(NSArray<DBXChainTask *> *)tasks {
    return [self executGroupTasks:tasks operate:[DBXOperate new]];
}

+ (instancetype)executGroupTasks:(NSArray<DBXChainTask *> *)tasks operate:(DBXOperate *)operate {
    DBXChainTask *tempTask = [self chainTask];
    tempTask.tempTask = YES;
    tempTask.subTasks = tasks;
    
    if (!tasks || tasks.count == 0) {
        [tempTask setResult:nil];
        return tempTask;
    }
    
    __block atomic_int resultCount = (int)tasks.count;
    
    NSLock *lock = [[NSLock alloc] init];
    // 存放所有任务的错误信息
    NSMutableDictionary *errorDic = [NSMutableDictionary dictionary];
    // 存放所有任务的结果信息
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];

    for (DBXChainTask *oneTask in tasks) {
        [oneTask thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
            [lock lock];
            if (task.error) {
                [errorDic setObject:task.error forKey:[task resultKey]];
            } else if (task.result) {
                [resultDic setObject:task.result forKey:[task resultKey]];
            }
            
            [lock unlock];
            if (atomic_fetch_sub(&resultCount, 1) == 1) {
                DBXLog(@"groupTask全部完成%@, 完成结果：%@，出错结果：%@", tempTask, resultDic, errorDic);
                // 任务全部结束后到了这里
                if (errorDic.count > 0) {
                    [tempTask setError:[NSError errorWithDomain:DBXChainTaskErrorDomain code:kDBXChainMultipleErrorsCode userInfo:errorDic]];
                } else {
                    [tempTask setResult:resultDic];
                }
            }

            return nil;
        } operate:operate];
    }
    return tempTask;
}

- (id)resultKey {
    return self.tag > 0 ? @(self.tag) : @(self.hash);
}

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block {
    return [self thenWithBlock:block operate:[DBXOperate new]];
}

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block operate:(DBXOperate *)operate {
    if (!operate) {
        operate = [DBXOperate new];
    }
    
    /**
     任务实际链接方式  task1 >> tempTask >> task2 >> tempTask >> task3 >> ...
     由于要保持可持续链接下去，返回值必须是一个task，而由于task2是异步获取的，因此需要创建一个临时的task过渡，作为虚拟的下一链子，代替还未获取到的task2，并同步task2的结果
     */
    DBXChainTask *tempTask = [DBXChainTask chainTask];
    tempTask.tempTask = YES;
    
    void (^executBlock)(void) = ^() {
        id result = block(self);
//        if (self.isTempTask) {
            DBXLog(@"task:%@完成，执行结果：%@", self, result);
//        }

        // 如果返回值是Task类型，则链条继续
        if ([result isKindOfClass:[DBXChainTask class]]) {
            DBXChainThenBlock tempThenBlock = ^id (DBXChainTask *task) {
                [tempTask copyInfoFrom:task];
                if (task.error) {
                    tempTask.error = task.error;
                } else {
                    tempTask.result = task.result;
                }
                return nil;
            };
            
            DBXChainTask *nextTask = (DBXChainTask *)result;
            if (nextTask.isCompleted) {
                tempThenBlock(nextTask);
            } else {
                [nextTask thenWithBlock:tempThenBlock];
            }
        } else if ([result isKindOfClass:[NSError class]]) {
            [tempTask setError:result];
        } else {
            [tempTask setResult:result];
        }
    };
    
    BOOL complete;
    [self.lock lock];
    // 任务未完成时，先将thenBlock包装后丢到数组中存起来，等任务完成后再执行
    complete = self.isCompleted;
    if (!complete) {
        void (^tempBlock)(void) = ^() {
            [operate operateBlock:executBlock];
        };
        [self.thenExecutBlocks addObject:tempBlock];
        [self tryTimeout];
    }
    [self.lock unlock];
    
    if (complete) {
        [operate operateBlock:executBlock];
    }
    return tempTask;
}

// 开启超时任务
- (void)tryTimeout {
    if (self.timeOutInterval <= 0) {
        [self closeTimer];
        return;
    }
    if (!_timeOutTimer) {
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeOutInterval target:self selector:@selector(timeOutAction) userInfo:nil repeats:NO];
    }
}

// 已超时
- (void)timeOutAction {
    if (self.error || self.result) {
        [self closeTimer];
        return;
    }
    self.error = [NSError errorWithDomain:@"DBXChainTask" code:-6666 userInfo:@{
        NSLocalizedDescriptionKey : @"任务已超时"
    }];
}

- (void)closeTimer {
    if (!_timeOutTimer) {
        return;
    }
    [_timeOutTimer invalidate];
    _timeOutTimer = nil;
}

- (void)setError:(NSError *)error {
    [self.lock lock];
    if (self.isCompleted) {
        [self.lock unlock];
        return;
    }
    _error = error;
    self.completed = YES;
    [self finishTask];
    [self.lock unlock];
}

- (void)setResult:(id)result {
    [self.lock lock];
    if (self.isCompleted) {
        [self.lock unlock];
        return;
    }
    _result = result;
    self.completed = YES;
    [self finishTask];
    [self.lock unlock];
}

// 执行剩余的所有回调，并清空
- (void)finishTask {
    [self.lock lock];
    for (void (^executBlock)(void) in self.thenExecutBlocks) {
        executBlock();
    }
    [self.thenExecutBlocks removeAllObjects];
    [self closeTimer];
    [self.lock unlock];
}

// 复制一个task信息
- (void)copyInfoFrom:(DBXChainTask *)task {
    self.taskName = task.taskName;
    self.subTasks = task.subTasks;
    self.tag = task.tag;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, taskName=%@, tag=%d, subTasksCount=%lu>", NSStringFromClass(self.class), self, self.taskName, (int)self.tag, (unsigned long)self.subTasks.count];
}

@end


@implementation NSError (DBXChain)

- (NSError *)dbx_errorWithTaskTag:(NSInteger)tag {
    if (self.code != kDBXChainMultipleErrorsCode) {
        return nil;
    }
    return [self.userInfo objectForKey:@(tag)];
}

- (NSError *)dbx_errorWithTask:(DBXChainTask *)task {
    if (self.code != kDBXChainMultipleErrorsCode) {
        return nil;
    }
    return [self.userInfo objectForKey:[task resultKey]];
}
@end
