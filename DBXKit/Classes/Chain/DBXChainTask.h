//
//  DBXChainTask.h
//  DBXKit
//
//  Created by asherluo on 2022/07/27.
//  Copyright © 2022 DBX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class DBXChainTask;
@class DBXOperate;

typedef id _Nullable (^DBXChainThenBlock)(DBXChainTask *task);

/// 链式任务
@interface DBXChainTask: NSObject<NSCopying>

@property(nonatomic, copy) DBXChainThenBlock ThenBlock;

/// 用于做些标识，非必要
@property(nonatomic, copy) NSString *taskName;

/// 用于grouptask，获取当前group里包含的task
@property(nonatomic, copy, readonly) NSArray *subTasks;

/// 超时，默认不超时
@property(nonatomic, assign) NSTimeInterval timeOutInterval;

/// 标记是否任务完成
@property(nonatomic, assign, readonly, getter=isCompleted) BOOL completed;

/// 任务执行出错的错误信息
@property(nonatomic, strong) NSError *error;

/// 任务执行后的结果
@property(nonatomic, strong, nullable) id result;

// 用于grouptask，获取当前任务的key
- (id)resultKey;

+ (instancetype)chainTask;

// group执行的任务，取对应task时要用resultKey取
+ (instancetype)executGroupTasks:(NSArray<DBXChainTask *> *)tasks;

+ (instancetype)executGroupTasks:(NSArray<DBXChainTask *> *)tasks operate:(DBXOperate *)operate;

/// 对应于executGroupTasks，从group task中获取单个task的error
+ (NSError *)errorOfTask:(DBXChainTask *)task fromGroupError:(NSError *)error;

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block;

/// task链式调用
/// @param block self完成之后调用的block，block返回值是下一个要执行的task，nil表示链式结束
/// @param operate 执行block的队列类型
- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block operate:(DBXOperate *)operate;

@end

NS_ASSUME_NONNULL_END
