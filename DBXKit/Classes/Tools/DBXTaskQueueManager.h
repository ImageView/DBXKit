//
//  DBXTaskQueueManager.h
//   
//
//  Created by 罗俊宇 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DBXMessageTaskFunc)(id  _Nonnull task, void (^taskFinished)(NSError *error));

#pragma mark - 队列
@interface DBXTaskQueue : NSObject
// 标识符
@property(nonatomic, copy) NSString *identifier;


/// 将任务添加到队列中，然后调用performTask执行
/// @param task 传入任务
/// @param taskFunc 执行任务的block环境，参数是当前identifier
/// return 任务是否添加成功，如果任务已经存在会返回NO
- (BOOL)addTask:(id<NSCopying>)task taskFunc:(nonnull DBXMessageTaskFunc)taskFunc;

/// 执行任务
- (void)performTask;

/// 执行对应identifier的任务
/// @param synchCount 支持同步执行的任务的数量
- (void)performTaskSynchCount:(NSInteger)synchCount;

/// 暂停任务队列
- (void)suspendTask;

/// 清理某个类下所有任务
- (void)clearTask;

/// 清理某个类下正在执行的任务数
- (void)clearTaskCount;

/// 任务是否全部执行完毕
- (BOOL)tasksHadFinish;

/// 任务是否已暂停
- (BOOL)taskIsSuspend;

@end


#pragma mark - 队列管理器
@interface DBXTaskQueueManager : NSObject


/// 注册一个队列
/// - Parameter identifier: 队列id
- (DBXTaskQueue *)registerQueue:(NSString *)identifier;

/// 根据id获取已经注册的队列，没有注册的返回nil
/// - Parameter identifier: 队列id
- (DBXTaskQueue *)fetchQueue:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
