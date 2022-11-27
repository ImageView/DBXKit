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

@interface DBXChainTask: NSObject

@property(nonatomic, copy) DBXChainThenBlock ThenBlock;

// 标记是否任务完成
@property(nonatomic, assign, readonly, getter=isCompleted) BOOL isCompleted;

// 任务执行出错的错误信息
@property(nonatomic, strong) NSError *error;

// 任务执行后的结果
@property(nonatomic, strong) id result;

+ (instancetype)chainTask;

- (DBXChainTask *)thenWithBlock:(DBXChainThenBlock)block;

@end

NS_ASSUME_NONNULL_END
