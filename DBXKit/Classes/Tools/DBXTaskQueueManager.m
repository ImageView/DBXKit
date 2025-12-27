//
//  DBXTaskQueueManager.m
//   
//
//  Created by 调包侠 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "DBXTaskQueueManager.h"
#import "DBXLog.h"

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
        DBXpLog(@"开始添加任务%@，该任务已存在，放弃添加", task);
        return NO;
    }
    DBXpLog(@"开始添加任务%@，任务进入队列", task);
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
    DBXpLog(@"启动队列:%@,funcDic:%@,taskCount:(%d/%d)",self.taskQueue, self.funcDictionary, self.taskingCount, synchCount);
    self.suspend = NO;
    if (self.taskingCount >= synchCount) {
        DBXpLog(@"任务已满，等待ing");
        return;
    }
    
    id task = self.taskQueue.firstObject;
    if (!task) {
        DBXpLog(@"队列已空");
        return;
    };
    
    void (^finishBlock)(NSError *error) = ^void(NSError *inError) {
        DBXpLog(@"任务:%@ 完成", task);
        self.taskingCount --;
        if (self.isSuspend) {
            DBXpLog(@"队列暂停");
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
    DBXpLog(@"开始任务:%@", task);
    [self.lock lock];
    self.taskingCount ++;
    [self.funcDictionary removeObjectForKey:task];
    [self.taskQueue removeObject:task];
    [self.lock unlock];
}

/// 暂停任务队列
- (void)suspendTask {
    self.suspend = YES;
    DBXpLog(@"暂停队列，正在执行的任务将继续执行");
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

// 队列管理器
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
    DBXTaskQueue *instance = [self.queuePool objectForKey:identifier];
    if (!instance) {
        instance = [[DBXTaskQueue alloc] init];
        instance.identifier = identifier;
        [self.queuePool setObject:instance forKey:identifier];
    }
    return instance;
}

- (DBXTaskQueue *)fetchQueue:(NSString *)identifier {
    return [self.queuePool objectForKey:identifier];
}

- (NSMutableDictionary *)queuePool {
    if (!_queuePool) {
        _queuePool = [NSMutableDictionary dictionary];
    }
    return _queuePool;
}

@end
