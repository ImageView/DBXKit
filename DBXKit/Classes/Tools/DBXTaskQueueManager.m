//
//  DBXTaskQueueManager.m
//   
//
//  Created by 罗俊宇 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "DBXTaskQueueManager.h"

@interface DBXTaskQueue ()

// 任务队列
@property(nonatomic, strong) NSMutableArray *taskQueue;
// 存储task对应的block
@property(nonatomic, strong) NSMutableDictionary *funcDictionary;
// 存储task正在执行的任务数量
@property(nonatomic, assign) NSInteger taskingCount;
// 队列是否暂停
@property(nonatomic, assign, getter=isSuspend) BOOL suspend;
@property(nonatomic, strong) NSLock *lock;

@end

@interface DBXTaskQueueManager ()

// 队列池
@property(nonatomic, strong) NSMutableDictionary *queuePool;

@end


@implementation DBXTaskQueue

- (BOOL)addTask:(id<NSCopying>)task taskFunc:(nonnull DBXMessageTaskFunc)taskFunc {
    if ([self.taskQueue containsObject:task]) {
        return NO;
    }
    [self.taskQueue addObject:task];
    [self.funcDictionary setObject:taskFunc forKey:task];
    return YES;
}

// 执行任务
- (void)performTask {
    [self performTaskSynchCount:1];
}

// synchCount 支持同时执行的任务的数量
- (void)performTaskSynchCount:(NSInteger)synchCount {
//    NSLog(@"队列开始执行，queueDic:%@,funcDic:%@,taskDic:%@",self.queueDictionary, self.funcDictionary, self.taskCountDictionary);
    self.suspend = NO;
    if (self.taskingCount >= synchCount) {
        return;
    }
    
    id task = self.taskQueue.firstObject;
    if (!task) {
        NSLog(@"task all finished");
        return;
    };
    
    void (^finishBlock)(NSError *error) = ^void(NSError *inError) {
        self.taskingCount --;
        if (self.isSuspend) {
            return;
        }
        [self performTaskSynchCount:synchCount];
    };
    DBXMessageTaskFunc func = [self.funcDictionary objectForKey:task];
    if (!func) {
        finishBlock(nil);
        return;
    }
    
    func(task, finishBlock);
    [self.lock lock];
    self.taskingCount ++;
    [self.funcDictionary removeObjectForKey:task];
    [self.taskQueue removeObject:task];
    [self.lock unlock];
}

/// 暂停任务队列
- (void)suspendTask {
    self.suspend = YES;
}

- (BOOL)taskIsSuspend {
    return self.isSuspend;
}
 
- (void)clearTaskCount {
    self.taskingCount = 0;
}

- (void)clearTask {
    [self clearTaskCount];
    [self.taskQueue removeAllObjects];
}

- (BOOL)tasksHadFinish {
    return self.taskQueue.count == 0;
}

#pragma mark - Getter
- (NSMutableArray *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = [NSMutableArray array];
    }
    return _taskQueue;
}

- (NSMutableDictionary *)funcDictionary {
    if (!_funcDictionary) {
        _funcDictionary = [NSMutableDictionary dictionary];
    }
    return _funcDictionary;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end

// 用于管理IM消息播放队列（礼物、超级推荐等）
@implementation DBXTaskQueueManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXTaskQueueManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}


// 注册一个队列
- (DBXTaskQueue *)registerQueue:(NSString *)identifier {
    DBXTaskQueue *instance = [[DBXTaskQueue alloc] init];
    instance.identifier = identifier;
    return instance;
}

- (NSMutableDictionary *)queuePool {
    if (!_queuePool) {
        _queuePool = [NSMutableDictionary dictionary];
    }
    return _queuePool;
}

@end
