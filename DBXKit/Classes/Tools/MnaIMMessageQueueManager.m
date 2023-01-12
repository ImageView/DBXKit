//
//  MnaIMMessageQueueManager.m
//  MnaTCloudIM
//
//  Created by 罗俊宇 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "MnaIMMessageQueueManager.h"

@interface MnaIMMessageQueueManager ()

// 存储类对应的队列
@property(nonatomic, strong) NSMutableDictionary *queueDictionary;
// 存储task对应的block
@property(nonatomic, strong) NSMutableDictionary *funcDictionary;
// 存储task正在执行的任务数量
@property(nonatomic, strong) NSMutableDictionary *taskCountDictionary;
// 是否进入到了后台
@property(nonatomic, assign) BOOL isBackground;

@end

// 用于管理IM消息播放队列（礼物、超级推荐等）
@implementation MnaIMMessageQueueManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotifications];
        self.taskStart = YES;
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
    [self performAllTasks];
}
    
- (void)applicationDidEnterBackground:(NSNotification *)nofication {
    self.isBackground = YES;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MnaIMMessageQueueManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)addTask:(id<NSCopying>)task forIdentifier:(NSString *)identifier taskFunc:(nonnull MnaIMMessageTaskFunc)taskFunc {
    NSMutableArray *taskQueue = [self currentTaskQueueOfIdentifier:identifier];
    if (!task) {
        return;
    }
    [taskQueue addObject:task];
    [self.funcDictionary setObject:taskFunc forKey:[self keyOfTask:task identifier:identifier]];
}

- (NSString *)keyOfTask:(id)task identifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"%@_%@",identifier,task];
}

- (void)performAllTasks {
    for (NSString *identifier in self.queueDictionary.allKeys) {
        if (!identifier) {
            continue;
        }
        [self performTaskOfIdentifier:identifier];
    }
}

// 执行某个类的任务
- (void)performTaskOfIdentifier:(NSString *)identifier {
    [self performTaskOfIdentifier:identifier synchCount:1];
}

// synchCount 支持同步执行的数量
- (void)performTaskOfIdentifier:(NSString *)identifier synchCount:(NSInteger)synchCount {
    if (!self.taskStart) {
        return;
    }
//    NSLog(@"队列开始执行，queueDic:%@,funcDic:%@,taskDic:%@",self.queueDictionary, self.funcDictionary, self.taskCountDictionary);
    // 进到后台后不执行任务
    if (self.isBackground) {
        return;
    }
    if ([self taskCountForIdentifier:identifier addOne:0] >= synchCount) {
        return;
    }
    NSMutableArray *taskQueue = [self currentTaskQueueOfIdentifier:identifier];
    id task = taskQueue.firstObject;
    if (!task) {
        return;
    }
    
    void (^nextBlock)(NSString *identifi) = ^void(NSString *inIdentifi) {
        [self taskCountForIdentifier:inIdentifi addOne:-1];
        dispatch_async(dispatch_get_current_queue(), ^{
            [self performTaskOfIdentifier:inIdentifi synchCount:synchCount];
        });
    };
    
    [taskQueue removeObjectAtIndex:0];
    NSString *funcKey = [self keyOfTask:task identifier:identifier];
    MnaIMMessageTaskFunc func = [self.funcDictionary objectForKey:funcKey];
    if (!func) {
        // 此处需要执行下一个任务，不然同名task多次插入时，func会在第一个task执行后被清理，后续的task就无法执行了
        nextBlock(identifier);
        return;
    }
    
    
    func(task, nextBlock);
    [self taskCountForIdentifier:identifier addOne:1];
    [self.funcDictionary removeObjectForKey:funcKey];
}

- (void)clearTaskCoundOfIdentifier:(NSString *)identifier {
    [self.taskCountDictionary removeObjectForKey:identifier];
}

- (void)clearTaskOfIdentifier:(NSString *)identifier {
    [self clearTaskCoundOfIdentifier:identifier];
    NSMutableArray *taskQueue = [self currentTaskQueueOfIdentifier:identifier];
    [taskQueue removeAllObjects];
}

// 根据类获取队列
- (NSMutableArray *)currentTaskQueueOfIdentifier:(NSString *)identifier {
    NSMutableArray *queue = [self.queueDictionary objectForKey:identifier];
    if (!queue) {
        queue = [NSMutableArray array];
        [self.queueDictionary setObject:queue forKey:identifier];
    }
    return queue;
}

// 读取当前class正在执行的任务数
- (NSInteger)taskCountForIdentifier:(NSString *)identifier addOne:(NSInteger)one {
    NSNumber *currCount = [self.taskCountDictionary objectForKey:identifier];
    if (![currCount isKindOfClass:[NSNumber class]]) {
        currCount = @(0);
    }
    NSInteger count = currCount.integerValue;
    if (one == 0) {
        return count;
    }
    count = count + one;
    [self.taskCountDictionary setObject:@(count) forKey:identifier];
    return count;
}

- (BOOL)tasksHadFinishOfIdentifier:(NSString *)identifier {
    NSMutableArray *taskQueue = [self currentTaskQueueOfIdentifier:identifier];
    return taskQueue.count > 0;
}

#pragma mark - Getter
- (NSMutableDictionary *)queueDictionary {
    if (!_queueDictionary) {
        _queueDictionary = [NSMutableDictionary dictionary];
    }
    return _queueDictionary;
}

- (NSMutableDictionary *)funcDictionary {
    if (!_funcDictionary) {
        _funcDictionary = [NSMutableDictionary dictionary];
    }
    return _funcDictionary;
}

- (NSMutableDictionary *)taskCountDictionary {
    if (!_taskCountDictionary) {
        _taskCountDictionary = [NSMutableDictionary dictionary];
    }
    return _taskCountDictionary;
}


@end
