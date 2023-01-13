//
//  MnaIMMessageQueueManager.h
//  MnaTCloudIM
//
//  Created by 罗俊宇 on 2022/1/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^MnaIMMessageTaskFunc)(id  _Nonnull task, void (^taskFinished)(NSString *identifier));

// 用于管理IM消息播放队列（礼物、超级推荐等）
@interface MnaIMMessageQueueManager : NSObject

+ (instancetype)sharedInstance;

/// 将任务添加到队列中，然后调用performTask执行
/// @param task 传入任务
/// @param identifier 标记任务所属的分类，用以存储及取出任务
/// @param taskFunc 执行任务的block环境，参数是当前identifier
- (void)addTask:(id<NSCopying>)task forIdentifier:(NSString *)identifier taskFunc:(nonnull MnaIMMessageTaskFunc)taskFunc;

/// 执行对应identifier的任务
- (void)performTaskOfIdentifier:(NSString *)identifier;

/// 执行对应identifier的任务
/// @param identifier 任务分类的id
/// @param synchCount 支持同步执行的任务的数量
- (void)performTaskOfIdentifier:(NSString *)identifier synchCount:(NSInteger)synchCount;

/// 清理某个类下所有任务
- (void)clearTaskOfIdentifier:(NSString *)identifier ;
/// 清理某个类下正在执行的任务数
- (void)clearTaskCoundOfIdentifier:(NSString *)identifier;
/// 执行所有identifier的任务
- (void)performAllTasks;
/// 对应identifier的任务是否全部执行完毕
- (BOOL)tasksHadFinishOfIdentifier:(NSString *)identifier;
/// 设置某个队列的任务状态：是否暂停
- (void)taskOfIdentifier:(NSString *)identifier pause:(BOOL)pause;
/// 某个任务是否暂停中，默认NO
- (BOOL)taskIsPauseOfIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
