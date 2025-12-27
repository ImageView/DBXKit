//
//  DBXTaskTimerManager.m
//   
//
//  Created by 调包侠 on 2022/6/20.
//  Copyright © 2022 Tencent. All rights reserved.
//
#import "DBXTaskTimerManager.h"
//  普通任务
@implementation DBXQueueItem
@end
//  循环任务
@implementation DBXCyclesQueueItem
@end


@interface DBXTaskTimerManager ()

// 定时任务队列
@property (nonatomic,strong) NSMutableDictionary * timerQueueDictionary;

// 循环任务队列
@property (nonatomic,strong) NSMutableDictionary *cycleQueueDictionary;
// 循环任务线程
@property (nonatomic, strong) NSThread *cycleThread;
// 循环任务定时器
@property (nonatomic, strong) NSTimer *cycleTimer;
// 轮询时间
@property (nonatomic, assign) NSTimeInterval cycleTimeInterval;

// 任务锁
@property (nonatomic, strong) NSLock *lock;
// 随机数池
@property (nonatomic,strong) NSMutableArray *randPool;
// 最大任务数量
@property (nonatomic, assign) NSInteger maxTaskCount;
@end

// 全局定时任务管理
@implementation DBXTaskTimerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DBXTaskTimerManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _cycleQueueDictionary = [NSMutableDictionary dictionary];
        _randPool = [NSMutableArray array];
        _maxTaskCount = 100;
        _cycleTimeInterval = 1;
        for (int i = 1 ; i < _maxTaskCount; i++) {
            [_randPool addObject:@(i)];
        }
        
        _cycleThread = [[NSThread alloc] initWithTarget:self selector:@selector(initialTimer) object:nil];
        _cycleThread.name = @"dbx-CycleQueue-thread";
        [_cycleThread start];
        
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
    if (self.cycleTimer) {
        [self.cycleTimer setFireDate:[NSDate distantPast]];
    }
}
    
- (void)applicationDidEnterBackground:(NSNotification *)nofication {
    if (self.cycleTimer) {
        [self.cycleTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - Public
- (DBXCyclesQueueItem*)addCycleTask:(dispatch_block_t)callback
                       timeInterval:(NSTimeInterval)time
                           runCount:(NSInteger)count
                         threadMode:(DBXThreadMode)mode {
    
    DBXCyclesQueueItem * item = [[DBXCyclesQueueItem alloc] init];
    item.callBack = callback;
    item.index = [self popRandIndex];
    item.timeInteval = time;
    item.nextRunDate = [[NSDate alloc] initWithTimeIntervalSinceNow:time];
    item.runCount = count;
    item.mode = mode;
    
    [self.cycleQueueDictionary setObject:item forKey:@(item.index)];
    // 启动循环定时器
    [self.cycleTimer setFireDate:[NSDate distantPast]];
    
    return item;
}

#pragma mark - Public End

- (void)initialTimer {
    _cycleTimer  = [NSTimer timerWithTimeInterval:self.cycleTimeInterval target:self selector:@selector(cycleRun) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.cycleTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)cycleRun {
    [self.lock lock];
    [self.cycleQueueDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, DBXCyclesQueueItem * obj, BOOL * _Nonnull stop) {
        // 如果还没有到执行时间,就跳过
        NSDate * currentDate = [NSDate date];
        if (obj.isPause || [obj.nextRunDate compare:currentDate] != NSOrderedAscending) {
            return;
        }
        
        switch (obj.mode) {
            case DBXThreadModeMain:
                [self performSelectorOnMainThread:@selector(runBlock:) withObject:obj waitUntilDone:NO];
                break;
                
            default:
                [self performSelectorInBackground:@selector(runBlock:) withObject:obj];
                break;
        }
        
        obj.nextRunDate = [[NSDate alloc] initWithTimeIntervalSinceNow:obj.timeInteval];
        
        if (obj.runCount > 0) {
            obj.runCount -= 1;
        }
        if (obj.runCount == 0) {
            [self removeCycleTask:obj];
        }
    }];
    [self.lock unlock];
}

- (void)runBlock:(DBXCyclesQueueItem*)item {
    if (item.callBack == nil) {
        [self removeTask:item];
        NSLog(@"DBXTaskTimer-remove:%@",item);
        return;
    }
    
    @try {
        item.callBack();
    } @catch (NSException *exception) {
        NSLog(@"DBXTaskTimer-ERROR:%@",exception);
        [self removeTask:item];
        NSLog(@"DBXTaskTimer-remove:%@",item);
    }
}

- (void)removeTask:(DBXCyclesQueueItem *)item {
    if (item.class == DBXCyclesQueueItem.class) {
        [self removeCycleTask:(DBXCyclesQueueItem*)item];
    }
}

- (void)removeCycleTask:(DBXCyclesQueueItem *)item {
    if (!item) {
        return;
    }
    [self.cycleQueueDictionary removeObjectForKey:@(item.index)];
    [self pushRandIndex:item.index];
    
    if (self.cycleQueueDictionary.allValues.count == 0){
        // 暂停定时器
        [_cycleTimer setFireDate:[NSDate distantFuture]];
    }
}

// 将下标还回pool池里
- (void)pushRandIndex:(NSInteger)index {
    [self.randPool addObject:@(index)];
}

// 从pool里随机弹出一个下标
- (NSInteger)popRandIndex{
    if (self.randPool.count == 0) {
        for (NSInteger i = _maxTaskCount; i < _maxTaskCount + 50; i++) {
            [self.randPool addObject:@(i)];
        }
    }
    NSInteger randomIndex =  arc4random()%self.randPool.count;
    NSNumber * index = [self.randPool objectAtIndex:randomIndex];
    [self.randPool removeObjectAtIndex:randomIndex];
    
    return index.integerValue;
}

@end
