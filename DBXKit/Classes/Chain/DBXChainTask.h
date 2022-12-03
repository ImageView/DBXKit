//
//  DBXChainTask.h
//  DBXKit
//
//  Created by asherluo on 2022/07/27.
//  Copyright © 2022 调包侠. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class DBXChainTask;

typedef id _Nullable (^DBXChainThenBlock)(DBXChainTask *task);

@interface DBXChainTask: NSObject<NSCopying>

@property(nonatomic, copy) DBXChainThenBlock ThenBlock;

// 用于做些标识，非必要
@property(nonatomic, copy) NSString *taskName;

// 标记是否任务完成
@property(nonatomic, assign, readonly, getter=isCompleted) BOOL isCompleted;

// 任务执行出错的错误信息
@property(nonatomic, strong) NSError *error;

// 任务执行后的结果
@property(nonatomic, strong, nullable) id result;

+ (instancetype)chainTask;

+ (instancetype)executGroupTasks:(NSArray<DBXChainTask *> *)tasks;

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block;

@end

NS_ASSUME_NONNULL_END
