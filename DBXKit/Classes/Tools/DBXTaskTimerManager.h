//
//  DBXTaskTimerManager.h
//   
//
//  Created by 罗俊宇 on 2022/6/20.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DBXThreadMode) {
    DBXThreadModeMain,
    DBXThreadModeBackground,
};

/// 加入的任务
@interface DBXQueueItem : NSObject

/// 任务描述
@property (nonatomic,copy) NSString *name;
/// 任务回调
@property (nonatomic,copy) dispatch_block_t callBack;
/// 任务执行模式
@property (nonatomic,assign) DBXThreadMode mode;
/// 任务的随机下标
@property (nonatomic,assign) NSInteger index;

@end

// 循环任务
@interface DBXCyclesQueueItem : DBXQueueItem
// 任务循环次数
@property (nonatomic,assign) NSInteger runCount;
// 下一次任务执行时间
@property (nonatomic,strong) NSDate * nextRunDate;
// 任务间隔
@property (nonatomic,assign) NSTimeInterval timeInteval;
// 任务是否已停止
@property (nonatomic,assign,readonly) BOOL isPause;

@end


// 全局定时任务管理
@interface DBXTaskTimerManager : NSObject

#pragma mark - 循环任务

+ (instancetype)sharedInstance;


/// 添加循环任务
/// @param callback 任务执行环境
/// @param time 任务间隔时间
/// @param count 任务执行次数，若小于0则无限循环
/// @param mode 任务执行在主/子线程
- (DBXQueueItem*)addCycleTask:(dispatch_block_t)callback timeInterval:(NSTimeInterval)time runCount:(NSInteger)count threadMode:(DBXThreadMode)mode;

- (void)removeTask:(DBXCyclesQueueItem *)item;

@end

NS_ASSUME_NONNULL_END
