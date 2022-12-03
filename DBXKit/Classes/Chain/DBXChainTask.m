//
//  DBXChainTask.m
//  DBXKit
//
//  Created by asherluo on 2022/07/27.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import "DBXChainTask.h"

NSString *const DBXChainTaskErrorDomain = @"GroupTasks error";
NSInteger const kBFMultipleErrorsError = 20180306;

@interface DBXChainTask ()

// 存储没有立即执行的block
@property(nonatomic, strong) NSMutableArray *thenExecutBlocks;
// 线程锁
@property(nonatomic, strong) NSLock *lock;

// 标记是否任务完成
@property(nonatomic, assign, getter=isCompleted) BOOL completed;

@end

@implementation DBXChainTask

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
    DBXChainTask *tempTask = [self chainTask];
    if (!tasks || tasks.count == 0) {
        [tempTask setResult:nil];
        return tempTask;
    }
    
    __block NSInteger resultCount = tasks.count;
    
    NSLock *lock = [[NSLock alloc] init];
    NSMutableDictionary *errorDic = [NSMutableDictionary dictionary];
    for (DBXChainTask *oneTask in tasks) {
        [oneTask thenWithBlock:^id _Nullable(DBXChainTask * _Nonnull task) {
            NSLog(@"%@任务完成  lock前",task );
            [lock lock];
            if (task.error) {
                [errorDic setObject:task.error forKey:task];
            }
            
            resultCount--;
            NSLog(@"%@任务完成  lock中，count%d",task, resultCount);
            [lock unlock];
            NSLog(@"%@任务完成  lock后",task );

            if (resultCount == 0) {
                // 任务全部结束后到了这里
                if (errorDic.count > 0) {
                    [tempTask setError:[NSError errorWithDomain:DBXChainTaskErrorDomain code:kBFMultipleErrorsError userInfo:errorDic.copy]];
                } else {
                    [tempTask setResult:nil];
                }
            }

            return nil;
        }];
    }
    return tempTask;
}

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block {
    /**
     表面是  task1 >> task2 >> task3 >> ...
     真实是  task1 >> tempTask >> task2 >> tempTask >> task3 >> ...
     由于要保持可持续链接下去，返回值必须是一个task，而由于task2是异步获取的，因此需要创建一个临时的task过渡，作为虚拟的下一链子，代替还未获取到的task2，并同步task2的结果
     */
    DBXChainTask *tempTask = [DBXChainTask chainTask];
    
    void (^executBlock)(void) = ^() {
        id result = block(self);
        
        // 如果返回值是Task类型，则链条继续
        if ([result isKindOfClass:[DBXChainTask class]]) {
            DBXChainThenBlock tempThenBlock = ^id (DBXChainTask *task) {
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
        }
    };
    
    BOOL complete;
    [self.lock lock];
    // 任务未完成时，先将thenBlock包装后丢到数组中存起来，等任务完成后再执行
    complete = self.isCompleted;
    if (!complete) {
        [self.thenExecutBlocks addObject:executBlock];
    }
    [self.lock unlock];
    
    if (complete) {
        executBlock();
    }
    return tempTask;
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
    [self.lock unlock];
}

@end
