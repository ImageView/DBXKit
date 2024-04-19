//
//  DBXTaskQueueManager.m
//  MnaTCloudIM
//
//  Created by 罗俊宇 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "DBXTaskQueueManager.h"

@interface DBXTaskQueueManager ()

// 任务队列
@property(nonatomic, strong) NSMutableArray *taskQueue;
// 存储task对应的block
@property(nonatomic, strong) NSMutableDictionary *funcDictionary;
// 存储task正在执行的任务数量
@property(nonatomic, assign) NSInteger taskingCount;
// 是否进入到了后台
@property(nonatomic, assign) BOOL isBackground;

@end

// 用于管理IM消息播放队列（礼物、超级推荐等）
@implementation DBXTaskQueueManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotifications];
    }
    return self;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.isBackground = NO;
//    [self performAllTasks];
}
    
- (void)applicationDidEnterBackground:(NSNotification *)nofication {
    self.isBackground = YES;
}

+ (instancetype)registerQueue:(NSString *)identifier {
    DBXTaskQueueManager *instance = [[DBXTaskQueueManager alloc] init];
    instance.identifier = identifier;
    return instance;
}

- (BOOL)addTask:(id<NSCopying>)task forIdentifier:(NSString *)identifier taskFunc:(nonnull MnaIMMessageTaskFunc)taskFunc {
    if (!task) {
        return NO;
    }
    if ([self.taskQueue containsObject:task]) {
        return NO;
    }
    [self.taskQueue addObject:task];
    [self.funcDictionary setObject:taskFunc forKey:task];
    return YES;
}

// 执行某个类的任务
- (void)performTaskOfIdentifier:(NSString *)identifier {
    [self performTaskOfIdentifier:identifier synchCount:1];
}

// synchCount 支持同步执行的数量
- (void)performTaskOfIdentifier:(NSString *)identifier synchCount:(NSInteger)synchCount {
    if ([self taskIsPauseOfIdentifier:identifier]) {
        return;
    }
//    NSLog(@"队列开始执行，queueDic:%@,funcDic:%@,taskDic:%@",self.queueDictionary, self.funcDictionary, self.taskCountDictionary);
    // 进到后台后不执行任务
    if (self.isBackground) {
        return;
    }
    if ([self taskCountAddOne:0] >= synchCount) {
        return;
    }
    id task = self.taskQueue.firstObject;
    if (!task) {
        return;
    }
    
    void (^nextBlock)(NSString *identifi) = ^void(NSString *inIdentifi) {
        [self taskCountAddOne:-1];
        dispatch_async(dispatch_get_current_queue(), ^{
            [self performTaskOfIdentifier:inIdentifi synchCount:synchCount];
        });
    };
    
    [self.taskQueue removeObjectAtIndex:0];
    
    MnaIMMessageTaskFunc func = [self.funcDictionary objectForKey:task];
    if (!func) {
        // 此处需要执行下一个任务，不然同名task多次插入时，func会在第一个task执行后被清理，后续的task就无法执行了
        nextBlock(identifier);
        return;
    }
    
    
    func(task, nextBlock);
    [self taskCountAddOne:1];
    [self.funcDictionary removeObjectForKey:task];
}

- (void)clearTaskCount {
    self.taskingCount = 0;
}

- (void)clearTask {
    [self clearTaskCount];
    [self.taskQueue removeAllObjects];
}

- (void)taskPause:(BOOL)pause {
    self.pause = pause;
}

- (BOOL)taskIsPause {
    return self.isPause;
}

// 读取当前class正在执行的任务数
- (NSInteger)taskCountAddOne:(NSInteger)one {
    self.taskingCount = self.taskingCount + one;
    return self.taskingCount;
}

- (BOOL)tasksHadFinishOfIdentifier:(NSString *)identifier {
    if ([self taskIsPauseOfIdentifier:identifier]) {
        return NO;
    }
    return self.taskQueue.count <= 0;
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

@end
